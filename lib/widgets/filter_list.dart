import 'package:flutter/material.dart';

class FilterList extends StatelessWidget {
  final List filters;
  final selectedIndex;

  final Function fetchData;
  FilterList(this.filters, this.fetchData, this.selectedIndex);
// by default first item will be selected

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.symmetric(vertical: 10),
      height: 30,
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => fetchData(index),
          child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(
              left: 20,
              // At end item it add extra 20 right  padding
              right: index == filters.length - 1 ? 20 : 0,
            ),
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: index == selectedIndex
                  ? Colors.white.withOpacity(0.4)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              filters[index],
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
