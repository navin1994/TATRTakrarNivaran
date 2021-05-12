import 'package:flutter/material.dart';

class PendingComplaintCard extends StatelessWidget {
  List complaints = [];
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 10),
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: complaints.length,
        itemBuilder: (context, index) => Container(
          margin: EdgeInsets.only(right: 20),
          child: Stack(
            children: [
              Transform(
                alignment: FractionalOffset.center,
                transform: Matrix4.identity()..rotateZ(-15 * 3.1415927 / 180),
                child: Container(
                  height: 210,
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(38)),
                ),
              ),
              Container(
                height: 210,
                width: 350,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(38)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Complaint Code : ',
                            style: TextStyle(color: Colors.amberAccent)),
                        Text('${complaints[index]['complaint-code']}',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                        Spacer(),
                        InkWell(
                          child: Text('View >>',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                          onTap: () {},
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text('Raised By : ',
                            style: TextStyle(color: Colors.amberAccent)),
                        Text('${complaints[index]['name']}',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: Row(
                        children: [
                          Text('Assigned To : ',
                              style: TextStyle(color: Colors.amberAccent)),
                          Text('Rajkumar Basant Banothe',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Category : ',
                            style: TextStyle(
                                fontSize: 18, color: Colors.amberAccent)),
                        Text('${complaints[index]['category']}',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text('Complaint Date',
                                style: TextStyle(color: Colors.amber)),
                            SizedBox(height: 3),
                            Text('${complaints[index]['date']}',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
