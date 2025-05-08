import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hfe_frontend/screens/screen.dart';
import 'package:url_launcher/url_launcher.dart';

class MedicalProfileHeader extends StatelessWidget {
  final String? nombre;
  final double? peso;
  final double? estatura;
  final String? contactoNombre;
  final String? contactoTelefono;
  final String? contactoRelacion;

  const MedicalProfileHeader({
    super.key,
    this.nombre,
    this.peso,
    this.estatura,
    this.contactoNombre,
    this.contactoTelefono,
    this.contactoRelacion,
  });

  Future<void> _handlePhoneNumberTap(BuildContext context) async {
    if (contactoTelefono == null || contactoTelefono == 'No registrado') {
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Contacto de emergencia',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.call, color: Colors.green),
                title: const Text('Llamar'),
                subtitle: Text(contactoTelefono!),
                onTap: () async {
                  final Uri phoneUri = Uri(
                    scheme: 'tel',
                    path: contactoTelefono,
                  );
                  
                  if (await canLaunchUrl(phoneUri)) {
                    await launchUrl(phoneUri);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No se pudo realizar la llamada'),
                        ),
                      );
                    }
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy, color: AppTheme.primary),
                title: const Text('Copiar al portapapeles'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: contactoTelefono!));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Número copiado al portapapeles'),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasBmi = peso != null && estatura != null && estatura! > 0;
    final bmi = hasBmi ? peso! / (estatura! * estatura!) : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary.withOpacity(0.8), AppTheme.secondary],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    nombre != null && nombre!.isNotEmpty
                        ? nombre![0].toUpperCase()
                        : "?",
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre ?? 'Cargando...',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.height,
                          size: 23,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          estatura != null
                              ? "${estatura!.toStringAsFixed(2)} m"
                              : "Estatura no registrada",
                          style: const TextStyle(color: Colors.white70, fontSize: 19.0),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.fitness_center,
                          size: 23,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          peso != null
                              ? "${peso!.toStringAsFixed(1)} kg"
                              : "Peso no registrado",
                          style: const TextStyle(color: Colors.white70, fontSize: 19.0),
                        ),
                      ],
                    ),
                    if (bmi != null) const SizedBox(height: 4),
                    if (bmi != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.monitor_weight,
                            size: 23,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "IMC: ${bmi.toStringAsFixed(1)}",
                            style: const TextStyle(color: Colors.white70, fontSize: 19.0),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white30),
          const SizedBox(height: 8),
          const Text(
            "Contacto de emergencia",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 23,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person, size: 23, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                contactoNombre ?? 'No registrado',
                style: const TextStyle(color: Colors.white, fontSize: 19.0),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.phone, size: 23, color: Colors.white70),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => _handlePhoneNumberTap(context),
                child: Row(
                  children: [
                    Text(
                      contactoTelefono ?? 'No registrado',
                      style: const TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        fontSize: 19.0,
                      ),
                    ),
                    if (contactoTelefono != null && contactoTelefono != 'No registrado')
                      const Icon(
                        Icons.arrow_drop_down,
                        size: 23,
                        color: Colors.white,
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (contactoRelacion != null) const SizedBox(height: 4),
          if (contactoRelacion != null)
            Row(
              children: [
                const Icon(
                  Icons.family_restroom,
                  size: 23,
                  color: Colors.white70,
                ),
                const SizedBox(width: 4),
                Text(
                  "Relación: $contactoRelacion",
                  style: const TextStyle(color: Colors.white, fontSize: 19.0),
                ),
              ],
            ),
        ],
      ),
    );
  }
}