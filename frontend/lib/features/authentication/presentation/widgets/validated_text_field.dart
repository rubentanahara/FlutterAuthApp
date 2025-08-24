import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ValidatedTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final String value;
  final String? errorText;
  final bool showError;
  final Function(String) onChanged;
  final VoidCallback? onEditingComplete;
  final Function(String)? onSubmitted;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autofocus;

  const ValidatedTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    required this.value,
    this.errorText,
    this.showError = true,
    required this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.controller,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.value);
    _focusNode = widget.focusNode ?? FocusNode();
    
    _focusNode.addListener(_onFocusChange);
    
    // Sync controller with value if using external controller
    if (widget.controller == null && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void didUpdateWidget(ValidatedTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update controller text if value changed externally
    if (widget.value != oldWidget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
      // Move cursor to end
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.showError && widget.errorText != null && widget.errorText!.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          enabled: widget.enabled,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          textCapitalization: widget.textCapitalization,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          onEditingComplete: widget.onEditingComplete,
          onFieldSubmitted: widget.onSubmitted,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            helperText: widget.helperText,
            prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
            suffixIcon: widget.suffixIcon,
            errorText: hasError ? widget.errorText : null,
            errorMaxLines: 2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError 
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError 
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: _hasFocus 
                ? Theme.of(context).colorScheme.surface
                : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
          ),
        ),
        
        // Real-time validation feedback
        if (hasError && widget.showError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 16),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// Password field with visibility toggle
class ValidatedPasswordField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final bool enabled;
  final String value;
  final String? errorText;
  final bool showError;
  final Function(String) onChanged;
  final VoidCallback? onEditingComplete;
  final Function(String)? onSubmitted;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autofocus;

  const ValidatedPasswordField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.enabled = true,
    required this.value,
    this.errorText,
    this.showError = true,
    required this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.controller,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  State<ValidatedPasswordField> createState() => _ValidatedPasswordFieldState();
}

class _ValidatedPasswordFieldState extends State<ValidatedPasswordField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return ValidatedTextField(
      labelText: widget.labelText,
      hintText: widget.hintText,
      helperText: widget.helperText,
      prefixIcon: Icons.lock_outline,
      suffixIcon: IconButton(
        icon: Icon(
          _isObscured ? Icons.visibility : Icons.visibility_off,
        ),
        onPressed: () {
          setState(() {
            _isObscured = !_isObscured;
          });
        },
        tooltip: _isObscured ? 'Show password' : 'Hide password',
      ),
      obscureText: _isObscured,
      enabled: widget.enabled,
      value: widget.value,
      errorText: widget.errorText,
      showError: widget.showError,
      onChanged: widget.onChanged,
      onEditingComplete: widget.onEditingComplete,
      onSubmitted: widget.onSubmitted,
      controller: widget.controller,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
    );
  }
}
