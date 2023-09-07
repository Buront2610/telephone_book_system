import 'package:flutter/material.dart';
import 'layout.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget tabletBody;
  final Widget desktopBody;

  const ResponsiveLayout({
    Key? key, 
    required this.mobileBody,
    required this.tabletBody,
    required this.desktopBody,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints){
        if(constraints.maxWidth < 600){
          return mobileBody;
        } else if(constraints.maxWidth < 1200){
          return tabletBody;
        } else {
          return desktopBody;
        }
      },
    );
  }
}