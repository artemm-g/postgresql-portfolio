from ModulDB import SqlQw

db = SqlQw()

print(db.create())
print(db.insert_into())

print(db.first_task())
print(db.second_task())
print(db.third_task())
print(db.last_task())

print("Представление 1:", db.show_view("first_task"))
print("Представление 2:", db.show_view("second_task"))
print("Представление 3:", db.show_view("third_task"))
print("Представление 4:", db.show_view("last_task"))

print(db.refresh_view("first_task"))
