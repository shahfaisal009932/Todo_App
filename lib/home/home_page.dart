import 'package:flutter/material.dart';
import 'package:database_11/data/db_helper.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomepageState();
}

class _HomepageState extends State<HomePage> {
  List<bool> isCheckedList = [];
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  DbHelper? dbHelper;

  int isChecked = 0;
  List<Map<String, dynamic>> allNotes = [];
  DateFormat df = DateFormat.yMMMEd();

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper.getInstance();
    getAllNotes();
  }

  void getAllNotes() async {
    allNotes = await dbHelper!.fetchNote();
    isCheckedList = List.generate(allNotes.length, (index) => false);

    setState(() {});
  }

  String selectedPriority = "Medium"; // default
  final List<String> priorities = ["High", "Medium", "Low"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(
              leading: Icon(Icons.search),
              controller: searchController,
              onChanged: (value) async {
                allNotes = await dbHelper!.fetchNote(query: value);
                isCheckedList = List.generate(
                  allNotes.length,
                  (index) => false,
                );
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: allNotes.length,
              itemBuilder: (_, index) {
                return Card(
                  child: ListTile(
                    leading: Checkbox(
                      value: allNotes[index][DbHelper.IS_COMPLETED] == 1,
                      onChanged: (value) async {
                        await dbHelper!.updateCompleted(
                          ID: allNotes[index][DbHelper.COLUMN_ID],
                          isCompleted: value! ? 1 : 0,
                        );
                        getAllNotes(); // refresh
                        // setState(() {
                        //   isCheckedList[index] = value!;
                        // });
                      },
                      activeColor: const Color.fromARGB(255, 15, 126, 177),
                    ),
                    title: Text(
                      allNotes[index][DbHelper.COLUMN_TITLE],
                      style: TextStyle(
                        decoration: allNotes[index][DbHelper.IS_COMPLETED] == 1
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          allNotes[index][DbHelper.COLUMN_DESC],
                          style: TextStyle(
                            decoration:
                                allNotes[index][DbHelper.IS_COMPLETED] == 1
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Created: ${df.format(DateTime.fromMillisecondsSinceEpoch(int.parse(allNotes[index][DbHelper.COLUMN_CREATED_AT])))}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: SizedBox(
                      width: 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            allNotes[index][DbHelper.PRIORITY] ?? "Medium",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  (allNotes[index][DbHelper.PRIORITY] == "High")
                                  ? Colors.red
                                  : (allNotes[index][DbHelper.PRIORITY] ==
                                        "Low")
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              titleController.text =
                                  allNotes[index][DbHelper.COLUMN_TITLE];
                              descController.text =
                                  allNotes[index][DbHelper.COLUMN_DESC];
                              selectedPriority =
                                  allNotes[index][DbHelper.PRIORITY] ??
                                  "Medium";
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(
                                        context,
                                      ).viewInsets.bottom,
                                    ),
                                    child: BottomUI(
                                      isUpdate: true,
                                      id: allNotes[index][DbHelper.COLUMN_ID],
                                    ),
                                  );
                                },
                              );
                            },
                            icon: Icon(Icons.edit),
                          ),
                          SizedBox(width: 5),
                          IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (_) {
                                  return Container(
                                    padding: EdgeInsets.all(11),
                                    height: 140,
                                    child: Column(
                                      children: [
                                        Text(
                                          "Are you Sure want to DELETE?",
                                          style: TextStyle(
                                            fontSize: 21,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 11),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            OutlinedButton(
                                              onPressed: () async {
                                                bool isDeleted = await dbHelper!
                                                    .deleteNote(
                                                      ID:
                                                          allNotes[index][DbHelper
                                                              .COLUMN_ID],
                                                    );
                                                if (isDeleted) {
                                                  getAllNotes();
                                                }
                                                Navigator.pop(context);
                                              },
                                              child: Text("YES"),
                                            ),
                                            SizedBox(width: 10),
                                            OutlinedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text("No"),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            icon: Icon(Icons.delete),
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: BottomUI(),
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget BottomUI({
    //String? selectedPriority,
    bool isUpdate = false,
    int id = 0,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isUpdate ? "Update Note" : "Add Note",
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 18),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              //prefixIcon: Icon(Icons.title),
              hintText: "enter title",
              hintStyle: TextStyle(color: Colors.grey.shade800),
              labelText: "Title",
              labelStyle: TextStyle(color: Colors.black87, fontSize: 18),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.lightBlueAccent),
              ),
            ),
          ),
          SizedBox(height: 12),
          TextField(
            minLines: 3,
            maxLines: 3,
            controller: descController,
            decoration: InputDecoration(
              //prefixIcon: Icon(Icons.description),
              hintText: "enter desc",
              hintStyle: TextStyle(color: Colors.grey.shade800),
              labelText: "desc",
              labelStyle: TextStyle(color: Colors.black87, fontSize: 18),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.lightBlueAccent),
              ),
            ),
          ),
          SizedBox(height: 18),
          StatefulBuilder(
            builder: (context, ss) {
              return Wrap(
                spacing: 10,
                children: priorities.map((priority) {
                  final isSelected = selectedPriority == priority;
                  return ChoiceChip(
                    label: Text(priority),
                    selected: isSelected,
                    //selectedColor: Colors.blue.shade100,
                    //labelStyle: TextStyle(
                    //  color: isSelected ? Colors.blue.shade900 : Colors.black,
                    //  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    // ),
                    onSelected: (_) {
                      ss(() {
                        selectedPriority = priority;
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
                width: 120,
                child: ElevatedButton(
                  onPressed: () async {
                    bool check = false;
                    if (titleController.text.isNotEmpty &&
                        descController.text.isNotEmpty) {
                      if (isUpdate) {
                        check = await dbHelper!.updateNote(
                          ID: id,
                          title: titleController.text,
                          desc: descController.text,
                          priority: selectedPriority,
                          isCompleted: allNotes.firstWhere(
                            (note) => note[DbHelper.COLUMN_ID] == id,
                          )[DbHelper.IS_COMPLETED],
                        );
                      } else {
                        check = await dbHelper!.addNote(
                          title: titleController.text,
                          desc: descController.text,
                          priority: selectedPriority,
                        );
                      }
                      if (check) {
                        getAllNotes();
                        titleController.clear();
                        descController.clear();
                        selectedPriority = "Medium";
                        Navigator.pop(context);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Please fill all the fields"),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  },
                  child: Text("Save", style: TextStyle(fontSize: 16)),
                ),
              ),
              SizedBox(width: 10),
              SizedBox(
                height: 50,
                width: 120,
                child: ElevatedButton(
                  onPressed: () {
                    titleController.clear();
                    descController.clear();
                    selectedPriority = "Medium"; // reset to default
                    Navigator.pop(context);
                  },
                  child: Text("Cancel", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} //
