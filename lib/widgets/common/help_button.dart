import 'package:flutter/material.dart';
import 'package:gastos/constants/app_colors.dart'; // Corregido
import 'package:gastos/widgets/help/keyboard_modal.dart'; // Corregido
import 'package:gastos/widgets/help/language_modal.dart'; // Corregido
import 'package:gastos/widgets/help/report_abuse_modal.dart'; // Corregido
import 'package:url_launcher/url_launcher.dart';

// Enum para manejar las acciones del menú
enum HelpMenuAction {
  helpCenter,
  forum,
  youtube,
  releaseNotes,
  legal,
  askCommunity,
  contactSupport,
  reportAbuse,
  keyboardLayout,
  changeLanguage
}

class HelpButton extends StatelessWidget {
  const HelpButton({super.key});

  // Función para lanzar URLs
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Podrías mostrar un snackbar aquí si falla
      debugPrint('No se pudo lanzar $urlString');
    }
  }

  // Manejador de acciones
  void _onActionSelected(BuildContext context, HelpMenuAction action) {
    // Cierra el menú emergente primero
    Navigator.of(context).pop();

    // Espera un momento para que el menú se cierre antes de abrir el modal
    Future.delayed(const Duration(milliseconds: 100), () {
      switch (action) {
      // --- Hipervínculos ---
        case HelpMenuAction.helpCenter:
          _launchURL('https://support.google.com'); // Reemplazar con tu URL
          break;
        case HelpMenuAction.forum:
          _launchURL('https://support.google.com/communities'); // Reemplazar con tu URL
          break;
        case HelpMenuAction.youtube:
          _launchURL('https://youtube.com'); // Reemplazar con tu URL
          break;
        case HelpMenuAction.releaseNotes:
          _launchURL('https://github.com/releases'); // Reemplazar con tu URL
          break;
        case HelpMenuAction.legal:
          _launchURL('https://google.com/policies'); // Reemplazar con tu URL
          break;
        case HelpMenuAction.askCommunity:
          _launchURL('https://stackoverflow.com'); // Reemplazar con tu URL
          break;
        case HelpMenuAction.contactSupport:
          _launchURL('mailto:soporte@serenidadfinanciera.com'); // Reemplazar con tu email
          break;

      // --- Modales ---
        case HelpMenuAction.reportAbuse:
          showDialog(context: context, builder: (ctx) => const ReportAbuseModal());
          break;
        case HelpMenuAction.keyboardLayout:
          showDialog(context: context, builder: (ctx) => const KeyboardModal());
          break;
        case HelpMenuAction.changeLanguage:
          showDialog(context: context, builder: (ctx) => const LanguageModal());
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<HelpMenuAction>(
      onSelected: (action) => _onActionSelected(context, action),
      iconSize: 28,
      offset: const Offset(0, -320), // Ajusta esto para posicionar el menú
      itemBuilder: (BuildContext context) => <PopupMenuEntry<HelpMenuAction>>[
        _buildPopupMenuItem(
          text: 'Centro de ayuda',
          value: HelpMenuAction.helpCenter,
        ),
        _buildPopupMenuItem(
          text: 'Foro de soporte',
          value: HelpMenuAction.forum,
        ),
        _buildPopupMenuItem(
          text: 'Videos de YouTube',
          value: HelpMenuAction.youtube,
        ),
        _buildPopupMenuItem(
          text: 'Notas de la versión',
          value: HelpMenuAction.releaseNotes,
        ),
        _buildPopupMenuItem(
          text: 'Resumen legal',
          value: HelpMenuAction.legal,
        ),
        const PopupMenuDivider(),
        _buildPopupMenuItem(
          text: 'Preguntar a la comunidad',
          value: HelpMenuAction.askCommunity,
        ),
        _buildPopupMenuItem(
          text: 'Comunicarse con soporte',
          value: HelpMenuAction.contactSupport,
        ),
        _buildPopupMenuItem(
          text: 'Denunciar abuso',
          value: HelpMenuAction.reportAbuse,
        ),
        const PopupMenuDivider(),
        _buildPopupMenuItem(
          text: 'Cambiar la disposición del teclado...',
          value: HelpMenuAction.keyboardLayout,
        ),
        _buildPopupMenuItem(
          text: 'Cambiar idioma...',
          value: HelpMenuAction.changeLanguage,
        ),
      ],
      // Este es el botón '?'
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primaryText.withOpacity(0.8),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: const Icon(
          Icons.question_mark_rounded,
          color: AppColors.background,
          size: 28,
        ),
      ),
    );
  }

  PopupMenuItem<HelpMenuAction> _buildPopupMenuItem(
      {required String text, required HelpMenuAction value}) {
    return PopupMenuItem<HelpMenuAction>(
      value: value,
      child: Text(text),
    );
  }
}