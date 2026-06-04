import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:provider/provider.dart';
import 'package:kap/l10n/app_localizations.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/database_service.dart';

class AddMemberBottomSheet extends StatefulWidget {
  const AddMemberBottomSheet({super.key});

  @override
  State<AddMemberBottomSheet> createState() => _AddMemberBottomSheetState();
}

class _AddMemberBottomSheetState extends State<AddMemberBottomSheet> {
  final _formKey = GlobalKey<ShadFormState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dbService = context.read<DatabaseService>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: KapColors.pureWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottom sheet handle/indicator
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24.0),
                  decoration: BoxDecoration(
                    color: KapColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                l10n.addMember,
                style: const TextStyle(
                  color: KapColors.slateDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 20),
              ShadForm(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Member Name Field
                    ShadInputFormField(
                      id: 'memberName',
                      label: Text(
                        l10n.memberName,
                        style: const TextStyle(
                          color: KapColors.slateDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      placeholder: Text(
                        l10n.enterMemberName,
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      validator: (v) {
                        if (v.trim().isEmpty) {
                          return l10n.memberNameRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    // Actions Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ShadButton.outline(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            l10n.cancel,
                            style: const TextStyle(color: KapColors.slateDark),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ShadButton(
                          backgroundColor: KapColors.slateDark,
                          hoverBackgroundColor: KapColors.slateDark.withValues(alpha: 0.8),
                          onPressed: () {
                            if (_formKey.currentState!.saveAndValidate()) {
                              final values = _formKey.currentState!.value;
                              final String name = (values['memberName'] as String).trim();

                              dbService.aileUyesiEkle(name);
                              Navigator.pop(context);
                            }
                          },
                          child: Text(
                            l10n.add,
                            style: const TextStyle(color: KapColors.pureWhite),
                          ),
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
