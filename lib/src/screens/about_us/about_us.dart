// ignore_for_file: library_private_types_in_public_api, camel_case_types

import 'dart:math';

import 'package:heathbridge_lao/package.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: ConstantColor.colorMain,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15)),
        ),
        centerTitle: true,
        title: const Text(
          'ກ່ຽວກັບພວກເຮົາ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        toolbarHeight: 70,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(left: 25, top: 20),
              child: AnimatedOpacity(
                opacity: 1,
                duration: Duration(
                  milliseconds: 1000,
                ),
                child: Text(
                  "ເເນະນໍາສະມາຊິກ",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: double.infinity,
              height: 645,
              child: PageViewWidget(),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 25, top: 0),
              child: Text(
                "ຈຸດປະສົງໃນການພັດທະນາແອັບ",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Stack(children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(top: 58),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade600,
                            spreadRadius: 4,
                            blurRadius: 5,
                            offset: const Offset(0, 5))
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Container(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      decoration: const BoxDecoration(),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 50,
                          ),
                          Text(
                            """ບົດໂຄງການຈົບຊັ້ນນີ້ເປັນການສຶກສາ, ຄົ້ນຄວ້າ ແລະ ສ້າງລະບົບແອັບພຣິເຄຊັນຄົ້ນຫາສະຖານທີ່ຕັ້ງໂຮງໝໍ, ຮ້ານຂາຍຢາ, ຄຣີນິກ Health Bridge Laos ເພື່ອຊ່ວຍເປັນສູນລວມຂໍ້ມູນຂອງສະຖານທີ່ທາງການແພດຕ່າງໆບໍ່ວ່າຈະເປັນໂຮງໝໍ, ຄຣີນິກ, ຮ້າຍນຂາຍຢາ ເເລະ ສະຖານທີ່ອື່ນໆທີ່ມີຢູ່ໃນນະຄອນຫຼວງວຽງຈັນ ໂດຍທີ່ບໍ່ຕ້ອງໄປຄົ້ນຫາຕາມອິນເຕີເນັດໃຫ້ຫຍຸ້ງຍາກ ເເລະ ປະຢັດເວລາອີກດ້ວຍ.""",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Align(
                  alignment: Alignment.topCenter,
                  child: CircleAvatar(
                    radius: 55.0,
                    backgroundColor: ConstantColor.colorMain,
                    child: CircleAvatar(
                      radius: 50.0,
                      backgroundColor: Color(0xff4E6859),
                      backgroundImage: AssetImage("assets/images/app-logo.png"),
                      child: Align(
                        alignment: Alignment.bottomRight,
                      ),
                    ),
                  )),
            ]),
            const SizedBox(
              height: 50,
            ),
            const SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}

class PageViewWidget extends StatefulWidget {
  const PageViewWidget({super.key});

  @override
  _PageViewWidgetState createState() => _PageViewWidgetState();
}

class _PageViewWidgetState extends State<PageViewWidget> {
  final List<AboutUs_> _list = AboutUs_.generate();

  PageController? pageController;

  double viewportFraction = 0.7;

  double? pageOffset = 0;

  @override
  void initState() {
    super.initState();
    pageController =
        PageController(initialPage: 0, viewportFraction: viewportFraction)
          ..addListener(() {
            setState(() {
              pageOffset = pageController!.page;
            });
          });
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      itemBuilder: (context, index) {
        double scale = max(viewportFraction,
            (1 - (pageOffset! - index).abs()) + viewportFraction);

        double angle = (pageOffset! - index).abs();

        if (angle > 0.4) {
          angle = 0.9 - angle;
        }
        return Container(
          decoration: const BoxDecoration(),
          margin: const EdgeInsets.only(right: 18),
          padding: EdgeInsets.only(
            right: 5,
            left: 5,
            top: 60 - scale * 25,
            bottom: 0,
          ),
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(
                3,
                2,
                0.001,
              )
              ..rotateY(angle),
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black,
                            spreadRadius: 4,
                            blurRadius: 5,
                            offset: Offset(0, 5))
                      ],
                    ),
                    child: Image.asset(
                      _list[index].url,
                      height: 400,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      alignment:
                          Alignment((pageOffset! - index).abs() * 0.5, 0),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: angle == 0 ? 1 : 0,
                  duration: const Duration(
                    milliseconds: 100,
                  ),
                  child: Text(
                    _list[index].name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: angle == 0 ? 1 : 0,
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  child: Text(
                    _list[index].title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    // overflow: TextOverflow.visible,
                    style: TextStyle(
                      color: Colors.black87.withOpacity(0.7),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.9,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: angle == 0 ? 1 : 0,
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  child: Text(
                    _list[index].class_,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      itemCount: _list.length,
    );
  }
}

class AboutUs_ {
  String url;
  String name;
  String title;
  String class_;

  AboutUs_(this.url, this.name, this.title, this.class_);

  static List<AboutUs_> generate() {
    return [
      AboutUs_(
        "assets/images/teacher.jpg",
        "ປ.ອ ສະຫວາດ\nໄຊປະດິດ",
        "ອາຈານນໍາພາ",
        "",
      ),
      AboutUs_(
        "assets/images/koon.jpg",
        "ປະຕິພານ\nວັນທານຸວົງ",
        "Developer",
        "4IT2",
      ),
      AboutUs_(
        "assets/images/phoy.jpg",
        "ເພັດວິໄລ\nຈັນດາຣາ",
        "Lead-Research and Documentation",
        "4IT2",
      ),
      AboutUs_(
        "assets/images/ko.jpg",
        "ວິທະຍາ\nກັນທະວົງ",
        "Co-Research, Data Analysis",
        "4IT2",
      ),
    ];
  }
}
