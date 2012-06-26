#include <stdio.h>
#include <sqlite3.h>
#include <stdlib.h>
#include <string.h>

#define TIME 2400
#define RESOLUTION 1000

struct lookup {
	int found;
	int id;
	int last;
	int name_length;
};

int main ()
{
	sqlite3 *db;
	char *sql;
	sqlite3_stmt *stmt;
	int nrecs;
	char *errmsg;
	int i;

	const int max = TIME * RESOLUTION;
	struct lookup table[max];

	memset(table, 0, sizeof(table));

	table[0].found = 1;

	sqlite3_open("songs.db", &db);

	sql = "SELECT * FROM songs WHERE genre = 'Rock' ORDER BY RANDOM() LIMIT 1000";
	sqlite3_prepare_v2(db, sql, strlen(sql) + 1, &stmt, NULL);

	while (1) {
		int s;

		s = sqlite3_step(stmt);
		if (s == SQLITE_ROW) {
			int id = sqlite3_column_int(stmt, 0);
			int time = sqlite3_column_int(stmt, 3);
			const unsigned char *name =
				sqlite3_column_text(stmt, 1);
			int name_length = strlen(name);

			if (time < 30000) {
				continue;
			}

			time *= RESOLUTION;
			time /= 1000;
			time += 1;

			for (i = max - 1; i >= 0; --i) {
				if (!table[i].found) {
					continue;
				}

				if (i + time >= max) {
					continue;
				}

				if (table[i + time].found) {
					continue;
				}

				table[i + time].found = 1;
				table[i + time].id = id;
				table[i + time].last = i;
				table[i + time].name_length = name_length;
			}
		} else if (s == SQLITE_DONE) {
			break;
		} else {
			fprintf(stderr, "Failed.\n");
			exit (1);
		}
	}

	if (table[max - 1].found) {
		i = max - 1;
		int total_time = 0;

		FILE *file = fopen("mixtape.txt", "w");

		while (i > 0) {
			if (1) {
				sql = "SELECT * FROM songs WHERE song_id = ?";
				sqlite3_prepare_v2(db, sql, strlen(sql) + 1, &stmt, NULL);
				sqlite3_bind_int(stmt, 1, table[i].id);

				int s = sqlite3_step(stmt);

				const unsigned char *name = sqlite3_column_text(stmt, 1);
				int time = sqlite3_column_int(stmt, 3);

				total_time += time;

				/*printf("%d: %s (%d)\n",*/
				       /*table[i].id,*/
				       /*name,*/
				       /*time);*/
			}

			fprintf(file, "%d\n", table[i].id);

			i = table[i].last;
		}

		fclose(file);

		printf("Total time: %d\n", total_time);
	}

	return 0;
}
