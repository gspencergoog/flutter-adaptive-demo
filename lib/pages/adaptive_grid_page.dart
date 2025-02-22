import 'dart:math';

import 'package:adaptive_app_demos/global/device_type.dart';
import 'package:adaptive_app_demos/global/styling.dart';
import 'package:adaptive_app_demos/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdaptiveGridPage extends StatefulWidget {
  @override
  _AdaptiveGridPageState createState() => _AdaptiveGridPageState();
}

class _AdaptiveGridPageState extends State<AdaptiveGridPage> {
  List<int> _listItems = List.generate(100, (index) => index);
  ScrollController _scrollController = ScrollController();

  List<int> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    // Create a list of widgets to render, inject .isSelected into each item
    Widget buildGridItem(int index) =>
        _GridItem(index, isSelected: _selectedItems.contains(index), onPressed: _handleItemPressed);
    List<Widget> listChildren = _listItems.map(buildGridItem).toList();
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        LogicalKeySet(LogicalKeyboardKey.keyA, LogicalKeyboardKey.control): SelectAllIntent(),
        LogicalKeySet(LogicalKeyboardKey.delete): DeleteIntent(),
      },
      child: Actions(
        actions: {
          SelectAllIntent: SelectAllAction(this._handleSelectAllPressed),
          DeleteIntent: DeleteAction(this._handleDeleteSelectedPressed),
        },
        child: Focus(
          child: Column(
            children: [
              Row(
                children: [
                  StyledTextButton(onPressed: _handleSelectAllPressed, child: Text("Select All")),
                  StyledTextButton(onPressed: _handleSelectNonePressed, child: Text("Select None")),
                ],
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    // Calculate how many columns we want depending on available space
                    int colCount = max(1, (constraints.maxWidth / 250).floor());
                    return Scrollbar(
                      isAlwaysShown: DeviceType.isDesktop,
                      controller: _scrollController,
                      child: GridView.count(
                          controller: _scrollController,
                          padding: EdgeInsets.all(Insets.extraLarge),
                          childAspectRatio: 1,
                          crossAxisCount: colCount,
                          children: listChildren),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSelectAllPressed() => setState(() => _selectedItems = List.from(_listItems));
  void _handleSelectNonePressed() => setState(() => _selectedItems.clear());
  void _handleDeleteSelectedPressed() => setState(() => _selectedItems.clear());

  void _handleItemPressed(int index) {
    setState(() {
      if (_selectedItems.contains(index))
        _selectedItems.remove(index);
      else
        _selectedItems.add(index);
    });
  }
}

class _GridItem extends StatelessWidget {
  const _GridItem(this.index, {Key? key, required this.isSelected, required this.onPressed}) : super(key: key);
  final int index;
  final bool isSelected;
  final void Function(int index) onPressed;

  @override
  Widget build(BuildContext context) {
    double borderWidth = isSelected ? 6 : 0;
    return Padding(
      padding: EdgeInsets.all(Insets.large),
      child: TextButton(
        onPressed: () => onPressed.call(index),
        child: Stack(children: [
          Center(child: FlutterLogo(size: 64)),
          Container(color: Colors.grey.withOpacity(isSelected ? .5 : .7)),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  width: double.infinity,
                  color: Colors.grey.shade600,
                  height: 50,
                  alignment: Alignment.center,
                  child: Text("Grid Item $index", style: TextStyle(color: Colors.white)))),
          // Selected border
          Container(decoration: BoxDecoration(border: Border.all(color: Colors.blue.shade200, width: borderWidth))),
        ]),
      ),
    );
  }
}

/// Actions and Intents to support keyboard shortcuts
class DeleteIntent extends Intent {}

class DeleteAction extends Action<DeleteIntent> {
  DeleteAction(this.action);
  final VoidCallback action;

  @override
  void invoke(covariant DeleteIntent intent) => action.call();
}

class SelectAllIntent extends Intent {}

class SelectAllAction extends Action<SelectAllIntent> {
  SelectAllAction(this.action);
  final VoidCallback action;

  @override
  void invoke(covariant SelectAllIntent intent) => action.call();
}
