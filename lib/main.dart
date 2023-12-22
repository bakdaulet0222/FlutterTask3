import 'dart:collection';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class Book {
  final int id;
  final String title;
  final String author;
  final String category;
  final List<Reader> borrowers;

  Book(this.id, this.title, this.author, this.category, this.borrowers);
}

class Reader {
  final int id;
  final String firstName;
  final String lastName;

  Reader(this.id, this.firstName, this.lastName);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Map<int, Book> library = {};
  List<Book> filteredLibrary = [];
  final List<Reader> readers = [
    Reader(1, "Иван ", "Петров"),
    Reader(2, "Анна ", "Сидорова"),
    Reader(3, "Михаил ", "Иванов"),
  ];
  late final Reader? selectedReader;
  final TextEditingController searchController = TextEditingController();
  final TextEditingController addTitleController = TextEditingController();
  final TextEditingController addAuthorController = TextEditingController();
  final TextEditingController addCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final defaultBooks = [
      Book(1, "Сто лет одиночества", "Габриэль Гарсиа Маркес", "Категория 1", []),
      Book(2, "Преступление и наказание", "Федор Достоевский", "Категория 2", []),
      Book(3, "Война и мир", "Лев Толстой", "Категория 3", []),
    ];

    for (final book in defaultBooks) {
      addBook(book.id, book.title, book.author, book.category);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Библиотека'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                filterLibrary(value);
              },
              decoration: InputDecoration(
                labelText: 'Поиск книги',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    filterLibrary('');
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: addCategoryController,
              onChanged: (value) {
                filterLibraryByCategory(value);
              },
              decoration: InputDecoration(
                labelText: 'Фильтр по категории',
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredLibrary.length,
              itemBuilder: (context, index) {
                final book = filteredLibrary[index];
                return ListTile(
                  title: Text(book.title),
                  subtitle: Text('${book.author} (${book.category})'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          showReadersListDialog(book);
                        },
                        child: Text('Список читателей'),
                      ),
                      SizedBox(width: 8), // Пространство между кнопками
                      ElevatedButton(
                        onPressed: () {
                          showBorrowDialog(book);
                        },
                        child: Text('+Читатель'),
                      ),
                    ],
                  ),
                );
              },
            )
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Добавить книгу'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: addTitleController,
                      decoration: InputDecoration(labelText: 'Название'),
                    ),
                    TextField(
                      controller: addAuthorController,
                      decoration: InputDecoration(labelText: 'Автор'),
                    ),
                    TextField(
                      controller: addCategoryController,
                      decoration: InputDecoration(labelText: 'Категория'),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Отмена'),
                  ),
                  TextButton(
                    onPressed: () {
                      final title = addTitleController.text;
                      final author = addAuthorController.text;
                      final category = addCategoryController.text;
                      final newId = library.length + 1;
                      addBook(newId, title, author, category);
                      Navigator.of(context).pop();
                    },
                    child: Text('Добавить'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void addBook(int id, String title, String author, String category) {
    final book = Book(id, title, author, category, []);
    setState(() {
      library[id] = book;
      filteredLibrary = library.values.toList();
    });
  }

  void removeBook(int id) {
    setState(() {
      library.remove(id);
      filteredLibrary.removeWhere((book) => book.id == id);
    });
  }

  void filterLibrary(String keyword) {
    setState(() {
      if (keyword.isEmpty) {
        filteredLibrary = library.values.toList();
      } else {
        filteredLibrary = library.values
            .where((book) =>
                book.title.toLowerCase().contains(keyword.toLowerCase()) ||
                book.author.toLowerCase().contains(keyword.toLowerCase()))
            .toList();
      }
    });
  }

  void showReadersListDialog(Book book) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Список читателей для "${book.title}"'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (book.borrowers.isEmpty)
                Text('У этой книги нет читателей.')
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: book.borrowers.map((reader) {
                    return ListTile(
                      title: Text('${reader.firstName} ${reader.lastName}'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          removeReaderFromBook(book, reader);
                        },
                        style: ElevatedButton.styleFrom(primary: Colors.red),
                        child: Text('Возврат'),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  void removeReaderFromBook(Book book, Reader reader) {
    setState(() {
      book.borrowers.remove(reader);
    });
    Navigator.of(context).pop(); // Закрываем диалоговое окно после удаления
  }


  void filterLibraryByCategory(String category) {
    setState(() {
      if (category.isEmpty) {
        filteredLibrary = library.values.toList();
      } else {
        filteredLibrary = library.values
            .where((book) =>
                book.category.toLowerCase().contains(category.toLowerCase()))
            .toList();
      }
    });
  }

  void borrowBook(Book book, Reader reader) {
    setState(() {
      book.borrowers.add(reader);
    });
  }

  void returnBook(Book book, Reader reader) {
    setState(() {
      book.borrowers.remove(reader);
    });
  }

  void showBorrowDialog(Book book) {
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Выдача книги'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Книга: ${book.title}'),
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: 'Имя читателя'),
              ),
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: 'Фамилия читателя'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                final firstName = firstNameController.text;
                final lastName = lastNameController.text;
                final newReaderId = readers.length + 1;
                addReader(newReaderId, firstName, lastName);
                final newReader = Reader(newReaderId, firstName, lastName);
                borrowBook(book, newReader);
                Navigator.of(context).pop();
              },
              child: Text('Выдать'),
            ),
          ],
        );
      },
    );
  }

  void addReader(int id, String firstName, String lastName) {
    final reader = Reader(id, firstName, lastName);
    setState(() {
      readers.add(reader);
    });
  }
}
