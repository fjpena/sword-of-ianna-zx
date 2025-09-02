// code created by Spirax with Copilot's help

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>

void write_word(FILE *f, uint16_t value) {
    fputc(value & 0xFF, f);          // byte bajo
    fputc((value >> 8) & 0xFF, f);   // byte alto
}

uint8_t checksum(uint8_t *data, size_t len) {
    uint8_t sum = 0;
    for (size_t i = 0; i < len; i++) sum ^= data[i];
    return sum;
}

void write_code_header(FILE *f, const char *name, uint16_t length, uint16_t addr) {
    uint8_t block[19] = {0};
    block[0] = 0x00;       // flag
    block[1] = 0x03;       // type: CODE

    // Rellenar nombre con espacios
    for (int i = 0; i < 10; i++) {
        block[2 + i] = (i < strlen(name)) ? name[i] : ' ';
    }

    block[12] = length & 0xFF;
    block[13] = (length >> 8) & 0xFF;
    block[14] = addr & 0xFF;
    block[15] = (addr >> 8) & 0xFF;
    block[16] = addr & 0xFF;       // param (same as addr)
    block[17] = (addr >> 8) & 0xFF;
    block[18] = checksum(&block[0], 18);

    write_word(f, 19);
    fwrite(block, 1, 19, f);
}

void write_block(FILE *f, uint8_t flag, uint8_t *data, uint16_t length) {
    write_word(f, length + 2);
    fputc(flag, f);
    fwrite(data, 1, length, f);
    uint8_t sum = flag;
    for (int i = 0; i < length; i++) sum ^= data[i];
    fputc(sum, f);
}

void list_existing_blocks(const char *filename) {
    FILE *f = fopen(filename, "rb");
    if (!f) return;

    printf("📦 Bloques existentes en %s:\n", filename);
    int index = 0;

    while (!feof(f)) {
        uint8_t len_lo = fgetc(f);
        uint8_t len_hi = fgetc(f);
        if (feof(f)) break;

        uint16_t length = len_lo | (len_hi << 8);
        uint8_t flag = fgetc(f);
        if (feof(f)) break;

        fseek(f, length - 2, SEEK_CUR);
        uint8_t checksum = fgetc(f);

        printf("  Bloque %d: longitud=%u, flag=0x%02X, checksum=0x%02X\n",
               index++, length, flag, checksum);
    }

    fclose(f);
    printf("🔚 Fin de bloques existentes\n\n");
}

void print_usage(const char *progname) {
    printf("Uso:\n  %s --out fichero.tap [--name loader --addr 0x6000] flag1 fichero1.raw [flag2 fichero2.raw ...]\n", progname);
}

int main(int argc, char *argv[]) {
    if (argc < 6) {
        print_usage(argv[0]);
        return 1;
    }

    const char *out_filename = NULL;
    const char *block_name = NULL;
    uint16_t load_addr = 0;
    int arg_index = 1;

    while (arg_index < argc) {
        if (strcmp(argv[arg_index], "--out") == 0 && arg_index + 1 < argc) {
            out_filename = argv[++arg_index];
        } else if (strcmp(argv[arg_index], "--addr") == 0 && arg_index + 1 < argc) {
            load_addr = (uint16_t)strtol(argv[++arg_index], NULL, 0);
        } else if (strcmp(argv[arg_index], "--name") == 0 && arg_index + 1 < argc) {
            block_name = argv[++arg_index];
        } else {
            break;
        }
        arg_index++;
    }

    // Validación: si se usa --name, también debe usarse --addr
    if ((block_name && !load_addr) || (!block_name && load_addr)) {
        fprintf(stderr, "⚠️ Error: si se usa --name, también debe usarse --addr (y viceversa).\n");
        return 1;
    }

    if (!out_filename || arg_index >= argc) {
        print_usage(argv[0]);
        return 1;
    }

    int file_exists = access(out_filename, F_OK) == 0;
    if (file_exists) {
        list_existing_blocks(out_filename);
    }

    FILE *out = fopen(out_filename, file_exists ? "ab" : "wb");
    if (!out) {
        perror("❌ No se pudo abrir el fichero de salida");
        return 1;
    }

    int first_block = 1;
    while (arg_index + 1 < argc) {
        uint8_t flag = (uint8_t)strtol(argv[arg_index], NULL, 0);
        const char *filename = argv[arg_index + 1];
        arg_index += 2;

        FILE *raw = fopen(filename, "rb");
        if (!raw) {
            fprintf(stderr, "❌ Error al abrir %s\n", filename);
            continue;
        }

        fseek(raw, 0, SEEK_END);
        long size = ftell(raw);
        rewind(raw);

        if (size > 0xFFFF) {
            fprintf(stderr, "⚠️ Archivo %s demasiado grande para un bloque TAP\n", filename);
            fclose(raw);
            continue;
        }

        uint8_t *buffer = malloc(size);
        fread(buffer, 1, size, raw);
        fclose(raw);

        // Añadir cabecera si es el primer bloque y se especificó --name y --addr
        if (first_block && block_name && load_addr) {
            write_code_header(out, block_name, (uint16_t)size, load_addr);
            printf("🧾 Añadida cabecera: nombre=%s, dirección=0x%04X, tamaño=%ld bytes\n",
                   block_name, load_addr, size);
            flag = 0xFF; // forzar flag de datos
        }

        write_block(out, flag, buffer, (uint16_t)size);
        free(buffer);

        printf("✅ Añadido bloque: flag=0x%02X, archivo=%s (%ld bytes)\n", flag, filename, size);
        first_block = 0;
    }

    fclose(out);
    printf("📁 Fichero TAP actualizado: %s\n", out_filename);
    return 0;
}
