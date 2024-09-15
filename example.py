import psycopg2 as pg



conn = pg.connect(
    host = "localhost",
    port = "5432",
    dbname = "CKeeper",
    user = "postgres",
    password = "raiderfeed08032005"
)

cur = conn.cursor()

cur.execute(
    "UPDATE post SET post_name = 'DELETE'"
)

try:
    conn.commit()
    print('Успешно')
    
except Exception as e:
    print(e)

cur.close()
conn.close()