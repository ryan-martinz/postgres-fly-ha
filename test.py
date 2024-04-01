import psycopg2
import time

db_params = {
    "dbname": "postgres",
    "user": "postgres",
    "password": "password",
    "host": "localhost",
    "port": 15432,
}

global_counter = [0]


def add_row(retry_attempts=6, retry_delay=10, counter=[0]):
    attempt = 0
    conn = None
    while attempt < retry_attempts:
        try:
            conn = psycopg2.connect(**db_params)
            with conn.cursor() as cur:
                cur.execute(
                    "INSERT INTO test2 (data) VALUES (%s);", (str(counter[0] + 1),)
                )
                conn.commit()
                counter[0] += 1
                print(f"Row added successfully with data: {counter[0]}")
                return
        except (psycopg2.OperationalError, psycopg2.errors.ReadOnlySqlTransaction) as e:
            print(f"Attempt {attempt + 1} failed due to operational error: {e}")
        except Exception as e:
            print(f"An unexpected error occurred: {e}")
        finally:
            if conn is not None:
                conn.close()
        time.sleep(retry_delay)
        attempt += 1
        retry_delay *= 2
    print("Failed to add row after multiple retry attempts.")


def main():
    try:
        while True:
            add_row(6, 10, global_counter)
            time.sleep(2)
    except KeyboardInterrupt:
        print("Script terminated by user.")


if __name__ == "__main__":
    main()
