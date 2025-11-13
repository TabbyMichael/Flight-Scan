import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomLoader extends StatefulWidget {
  final String message;
  final bool useIOSStyle;

  const CustomLoader({
    super.key,
    this.message = 'Loading...',
    this.useIOSStyle = true,
  });

  @override
  State<CustomLoader> createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<CustomLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.useIOSStyle)
          RotationTransition(
            turns: _animation,
            child: const CupertinoActivityIndicator(
              radius: 16,
            ),
          )
        else
          RotationTransition(
            turns: _animation,
            child: const CircularProgressIndicator(),
          ),
        const SizedBox(height: 16),
        Text(
          widget.message,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}