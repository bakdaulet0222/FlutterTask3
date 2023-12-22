import 'reader.dart'; // Импортируйте файл reader.dart

class Book {
  final int id;
  final String title;
  final String author;
  final String category;
  final List<Reader> borrowers;

  Book(this.id, this.title, this.author, this.category, this.borrowers);
}

void borrowBook(Book book, Reader reader) {
  book.borrowers.add(reader);
}

void returnBook(Book book, Reader reader) {
  book.borrowers.remove(reader);
}

void removeReaderFromBook(Book book, Reader reader) {
  book.borrowers.remove(reader);
}