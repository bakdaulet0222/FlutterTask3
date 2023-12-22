

class Reader {
  final int id;
  final String firstName;
  final String lastName;

  Reader(this.id, this.firstName, this.lastName);
}

// Определите список читателей в этом файле
final List<Reader> readers = [];

// Функция для добавления читателя в список
void addReader(int id, String firstName, String lastName) {
  final reader = Reader(id, firstName, lastName);
  readers.add(reader);
}