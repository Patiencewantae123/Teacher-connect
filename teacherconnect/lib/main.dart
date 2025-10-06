// main.dart - Teacher Connect
// Flutter 3.x+ compatible, null safety enabled

import 'package:flutter/material.dart';

void main() {
  runApp(TeacherConnectApp());
}

class TeacherConnectApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teacher Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScaffold(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DashboardPage(),
    MessagesPage(),
    ClassesPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int idx) {
    setState(() {
      _selectedIndex = idx;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Connect'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: SimpleSearch());
            },
          )
        ],
      ),
      drawer: AppDrawer(onSelect: (i) {
        Navigator.pop(context); // close drawer
        _onItemTapped(i);
      }),
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.class_), label: 'Classes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: _selectedIndex == 2
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateClass(context),
              label: Text('New Class'),
              icon: Icon(Icons.add),
            )
          : null,
    );
  }

  void _showCreateClass(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: CreateClassForm(onCreated: (newClass) {
          // For demo: show snackbar
          Navigator.of(ctx).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Class "${newClass.name}" created')),
          );
        }),
      ),
    );
  }
}

// ------------------------
// Drawer
// ------------------------
class AppDrawer extends StatelessWidget {
  final void Function(int) onSelect;
  const AppDrawer({Key? key, required this.onSelect}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 28, child: Icon(Icons.person, size: 30)),
                SizedBox(height: 12),
                Text('Patience Wangui', style: TextStyle(color: Colors.white, fontSize: 18)),
                Text('Teacher', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Home'),
            onTap: () => onSelect(0),
          ),
          ListTile(
            leading: Icon(Icons.message),
            title: Text('Messages'),
            onTap: () => onSelect(1),
          ),
          ListTile(
            leading: Icon(Icons.class_),
            title: Text('Classes'),
            onTap: () => onSelect(2),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage()));
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log out'),
            onTap: () {
              // implement real auth in production
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logged out')));
            },
          ),
        ],
      ),
    );
  }
}

// ------------------------
// Pages
// ------------------------
class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back, Patience', style: Theme.of(context).textTheme.headline6),
          SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.announcement),
              title: Text('Announcements'),
              subtitle: Text('No new announcements'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: [
                SectionHeader(title: 'Upcoming Classes'),
                ClassTile(
                  name: 'Biology 101',
                  time: 'Mon 10:00',
                  students: 28,
                ),
                ClassTile(name: 'Physics Practical', time: 'Tue 14:00', students: 18),
                SizedBox(height: 12),
                SectionHeader(title: 'Recent Messages'),
                MessagePreview(sender: 'John Mwangi', text: 'Thanks for the notes!'),
                MessagePreview(sender: 'School Admin', text: 'Meeting at 3pm today'),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MessagesPage extends StatelessWidget {
  final List<Map<String, String>> _dummy = [
    {'name': 'John Mwangi', 'preview': 'Can you share slides?'},
    {'name': 'Mary A.', 'preview': 'Absent today'},
    {'name': 'Admin', 'preview': 'Term report due'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(8),
      itemCount: _dummy.length,
      itemBuilder: (_, i) => ListTile(
        leading: CircleAvatar(child: Text(_dummy[i]['name']![0])),
        title: Text(_dummy[i]['name']!),
        subtitle: Text(_dummy[i]['preview']!),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(name: _dummy[i]['name']!))),
      ),
      separatorBuilder: (_, __) => Divider(),
    );
  }
}

class ClassesPage extends StatelessWidget {
  final List<ClassModel> classes = [
    ClassModel(name: 'Biology 101', students: 28, schedule: 'Mon 10:00'),
    ClassModel(name: 'Maths - Form 2', students: 32, schedule: 'Wed 09:00'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: classes.length,
      itemBuilder: (_, i) => Card(
        child: ListTile(
          leading: Icon(Icons.class_),
          title: Text(classes[i].name),
          subtitle: Text('${classes[i].schedule} • ${classes[i].students} students'),
          trailing: Icon(Icons.chevron_right),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClassDetailPage(cls: classes[i]))),
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(radius: 44, child: Icon(Icons.person, size: 44)),
          SizedBox(height: 12),
          Text('Patience Wangui', style: Theme.of(context).textTheme.headline6),
          Text('Science Teacher • Nairobi'),
          SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: Icon(Icons.email),
              title: Text('patience@example.com'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.phone),
              title: Text('+254 7XX XXX XXX'),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------
// Smaller widgets & forms
// ------------------------
class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({Key? key, required this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      );
}

class ClassTile extends StatelessWidget {
  final String name, time;
  final int students;
  const ClassTile({Key? key, required this.name, required this.time, required this.students}) : super(key: key);
  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          title: Text(name),
          subtitle: Text('$time • $students students'),
          trailing: Icon(Icons.chevron_right),
          onTap: () {},
        ),
      );
}

class MessagePreview extends StatelessWidget {
  final String sender, text;
  const MessagePreview({Key? key, required this.sender, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) => ListTile(
        leading: CircleAvatar(child: Text(sender[0])),
        title: Text(sender),
        subtitle: Text(text),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(name: sender))),
      );
}

class SimpleSearch extends SearchDelegate<String> {
  final List<String> sample = ['Biology', 'Maths', 'John Mwangi', 'Announcements'];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: Icon(Icons.arrow_back), onPressed: () => close(context, ''));
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(child: Text('Search result for "$query"'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty ? sample : sample.where((s) => s.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (_, i) => ListTile(
        title: Text(suggestions[i]),
        onTap: () => query = suggestions[i],
      ),
    );
  }
}

class CreateClassForm extends StatefulWidget {
  final void Function(ClassModel) onCreated;
  CreateClassForm({required this.onCreated});

  @override
  _CreateClassFormState createState() => _CreateClassFormState();
}

class _CreateClassFormState extends State<CreateClassForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _scheduleCtrl = TextEditingController();
  final _studentsCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _scheduleCtrl.dispose();
    _studentsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Create New Class', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            TextFormField(controller: _nameCtrl, decoration: InputDecoration(labelText: 'Class name'), validator: (v) => v == null || v.isEmpty ? 'Enter name' : null),
            TextFormField(controller: _scheduleCtrl, decoration: InputDecoration(labelText: 'Schedule e.g. Mon 10:00')),
            TextFormField(controller: _studentsCtrl, decoration: InputDecoration(labelText: 'Students count'), keyboardType: TextInputType.number),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final cls = ClassModel(
                        name: _nameCtrl.text.trim(),
                        schedule: _scheduleCtrl.text.trim(),
                        students: int.tryParse(_studentsCtrl.text.trim()) ?? 0,
                      );
                      widget.onCreated(cls);
                    }
                  },
                  child: Text('Create'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

// ------------------------
// Detail pages
// ------------------------
class ClassDetailPage extends StatelessWidget {
  final ClassModel cls;
  const ClassDetailPage({Key? key, required this.cls}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(cls.name)),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Schedule: ${cls.schedule}'),
            SizedBox(height: 8),
            Text('Students: ${cls.students}'),
            SizedBox(height: 16),
            ElevatedButton.icon(onPressed: () {}, icon: Icon(Icons.upload_file), label: Text('Share Notes')),
          ],
        ),
      ),
    );
  }
}

class ChatPage extends StatelessWidget {
  final String name;
  const ChatPage({Key? key, required this.name}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Column(
        children: [
          Expanded(child: Center(child: Text('Conversation with $name'))),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(decoration: InputDecoration(hintText: 'Type a message'))),
                IconButton(icon: Icon(Icons.send), onPressed: () {}),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(value: true, onChanged: (_) {}, title: Text('Notifications')),
          ListTile(title: Text('Account'), onTap: () {}),
        ],
      ),
    );
  }
}

// ------------------------
// Models
// ------------------------
class ClassModel {
  final String name;
  final String schedule;
  final int students;
  ClassModel({required this.name, this.schedule = '', this.students = 0});
}

