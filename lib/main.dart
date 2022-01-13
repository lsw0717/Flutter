import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart'; //온갖거 모든 권한을 가져오기 위한 라이브러리(패키지)
import 'package:contacts_service/contacts_service.dart'; //연락처를 꺼내기 위한 라이브러리(패키지)

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'second app',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //권한을 가져오는 함수(복붙하기)(패키지 사용법임)
  getPermission() async {
    //연락처 권한 줬는지 여부 상태
    var status = await Permission.contacts.status;
    //연락처 권한을 줬을 때
    if (status.isGranted) {
      print('허락됨');
      takecontent();
    }
    //연락처 권한을 안줬을 때
    else if (status.isDenied) {
      print('거절됨');
      //연락처 권한 허락해달라고 팝업 띄우는 코드
      Permission.contacts.request();
    }
    //아예 앱 설정해서 권한을 꺼놓은 경우
    else if (status.isPermanentlyDenied) {
      //앱 설정 화면을 켜줌//직접 사용자가 권한을 설정하라고.
      openAppSettings();
    }
  }

  //폰의 연락처를 어플로 가져오는 함수
  takecontent() async {
    //폰의 연락처를 어플로 가져오기
    var contacts = await ContactsService.getContacts(withThumbnails: false);

    //contacts[0].phones = [Item(label:mobile, value:전화번호), Item(label:home, value:전화번호)]

    //contacts의 리스트 개수만큼 반복문 실행.
    for (int i = 0; i < contacts.length; i++) {
      nameadd(contacts[i].givenName.toString());
      numberadd(contacts[i].phones![0].value.toString());
    }
  }

  //FAB에서 OK 버튼 누르면 ListTile에 신규 contact가 추가 됨과 동시에, 핸드폰의 주소록에도 추가.
  addatphone(String name, String num) async {
    List<Item> number = [Item(label: 'mobile', value: num)];
    var newcontacts = Contact(givenName: name, phones: number);
    await ContactsService.addContact(newcontacts);
  }

  //위젯이 로드 될 때, 최초 1회 실행.
  // @override
  // void initState() {
  //   super.initState();
  //   getPermission();
  // }

  List<List<String>> name = [
    ['빠더', '01071557680'],
    ['어마마마', '01023527680'],
    ['브라더', '01036257670']
  ];
  //부모 state를 자식(DialogUI)이 수정할 수 있도록 하는 함수. => 자식위젯에 전달, 등록, 사용
  nameadd(String a) {
    setState(() {
      name.add(List.generate(
          2, (index) => 'null')); //2d리스트에 1d리스트(['null','null']) 추가
      debugPrint(name.length.toString());
      name[name.length - 1][0] = a; //추가한 ['null','null']의 인덱스0 요소를 'a'로 바꿈.
    });
  }

  numberadd(String b) {
    setState(() {
      name[name.length - 1][1] = b;
    });
  }

//부모 state를 자식(DeleteDialogUI)이 수정할 수 있도록 하는 함수. => 자식위젯에 전달, 등록, 사용
  namedelete(int a) {
    setState(() {
      //리스트의 index==a 번째의 리스트를 삭제
      name.removeAt(a);
    });
  }

//리스트name 가나다순 정렬 함수.
  namesort(List a) {
    setState(() {
      //sort() 리스트 정렬 함수.
      //인덱스0 1d리스트[0] 과, 인덱스1 1d리스트[0]을 비교해서 오름차순 정렬.
      a.sort((a, b) => a[0].compareTo(b[0]));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return DialogUI(
                    nameadd: nameadd,
                    numberadd: numberadd,
                    addatphone: addatphone);
              });
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text('CONTACTS'),
        centerTitle: true,
        elevation: 0.0,
        //actions: appbar에서 오른쪽에 위치한 아이콘
        actions: [
          IconButton(
            icon: Icon(Icons.restart_alt),
            onPressed: () {
              print('shoping cart button is clicked');
              //버튼 클릭시, 전화번호 ListTile 가나다순 정렬.
              namesort(name);
            },
          ),
          IconButton(
            icon: Icon(Icons.contacts),
            onPressed: () {
              print('search icon is clicked');
              getPermission();
            },
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text('Gosegu'),
              accountEmail: Text('gosegu@gmail.com'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/gosegu.jpg'),
              ),
              otherAccountsPictures: [
                CircleAvatar(
                  backgroundImage: AssetImage('assets/gosegu.jpg'),
                ),
              ],
              onDetailsPressed: () {
                debugPrint('detail button is clicked');
              },
              decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40.0),
                      bottomRight: Radius.circular(40.0))),
            ),
            ListTile(
              leading: Icon(
                Icons.home,
                color: Colors.grey[850],
              ),
              title: Text('Home'),
              trailing: Icon(
                Icons.add,
                color: Colors.grey[850],
              ),
              onTap: () {
                debugPrint('Home button is clicked');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.settings,
                color: Colors.grey[850],
              ),
              title: Text('settings'),
              trailing: Icon(
                Icons.add,
                color: Colors.grey[850],
              ),
              onTap: () {
                debugPrint('settings button is clicked');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.question_answer,
                color: Colors.grey[850],
              ),
              title: Text('Q&A'),
              trailing: Icon(
                Icons.add,
                color: Colors.grey[850],
              ),
              onTap: () {
                debugPrint('question_answer button is clicked');
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
          itemCount: name.length,
          itemBuilder: (context, i) {
            return Card(
              child: ListTile(
                leading: Icon(
                  Icons.account_circle,
                  color: Colors.grey[850],
                ),
                title: Text(
                  name[i][0],
                  style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0),
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.grey[850],
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          // i 는 ListView.Builder의 ItemBuilder: i 이다.
                          return DeleteDialogUI(
                            index: i,
                            namedelete: namedelete,
                          );
                        });
                  },
                ),
                onTap: () {
                  debugPrint(name[i].toString());
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return DetailDialogUI(index: i, name: name);
                      });
                },
              ),
            );
          }),
    );
  }
}

//DialogUI Custom Widget
// ignore: must_be_immutable
class DialogUI extends StatelessWidget {
  DialogUI({Key? key, this.nameadd, this.numberadd, this.addatphone})
      : super(key: key);
  var inputNameData = TextEditingController();
  var inputNumberData = TextEditingController();

  final nameadd;
  final numberadd;
  final addatphone;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Contact'),
      content: SizedBox(
        height: 100,
        child: Column(
          children: [
            TextField(
              controller: inputNameData,
              decoration: InputDecoration(hintText: 'add Name'),
            ),
            TextField(
              controller: inputNumberData,
              decoration: InputDecoration(hintText: 'add phone number'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel')),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
              //string null, OR, start with '(blank)',  do not make listTile
              if (inputNameData.text.isEmpty ||
                  inputNameData.text.startsWith(' ') ||
                  inputNumberData.text.isEmpty ||
                  inputNumberData.text.startsWith(' ')) {
              } else {
                nameadd(inputNameData.text);
                numberadd(inputNumberData.text);
                addatphone(inputNameData.text, inputNumberData.text);
              }
            },
            child: Text('Ok'))
      ],
    );
  }
}

//DeleteDialogUI Custom Widget
class DeleteDialogUI extends StatelessWidget {
  const DeleteDialogUI({
    Key? key,
    this.index,
    this.namedelete,
  }) : super(key: key);
  final index;
  final namedelete;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete Contact'),
      content: Text('Are you sure to delete?'),
      //Text(name[index].toString())
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel')),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              namedelete(index);
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Contact Delete Completely'),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Done')),
                      ],
                    );
                  });
            },
            child: Text('Yes')),
      ],
    );
  }
}

//DetailDialogUI Custom Widget : Card: ListTile : onTap()
class DetailDialogUI extends StatelessWidget {
  const DetailDialogUI({Key? key, this.index, this.name}) : super(key: key);
  final index;
  final name;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(name[index][0].toString(),
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        height: 50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ('Tel.'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 5,
            ),
            Text(name[index][1].toString()),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Done'))
      ],
    );
  }
}
