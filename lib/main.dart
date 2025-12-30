import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() => runApp(const DynamicQRApp());

class DynamicQRApp extends StatelessWidget {
  const DynamicQRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const QRGeneratorScreen(),
    );
  }
}

class QRGeneratorScreen extends StatefulWidget {
  const QRGeneratorScreen({super.key});

  @override
  State<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  // State Variables
  String _selectedType = "URL";
  final TextEditingController _inputController = TextEditingController(text: "https://google.com");
  bool _isTrackingEnabled = false;
  String _expandedSection = "FRAME"; // Tracks which accordion is open

  // Data for the Grid
  final List<Map<String, dynamic>> _qrTypes = [
    {"icon": Icons.link, "label": "URL"},
    {"icon": Icons.contact_page, "label": "VCARD"},
    {"icon": Icons.text_fields, "label": "TEXT"},
    {"icon": Icons.email, "label": "E-MAIL"},
    {"icon": Icons.sms, "label": "SMS"},
    {"icon": Icons.wifi, "label": "WIFI"},
    {"icon": Icons.currency_bitcoin, "label": "BITCOIN"},
    {"icon": Icons.picture_as_pdf, "label": "PDF"},
    {"icon": Icons.music_note, "label": "MP3"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: _buildAppBar(),
      body: Row(
        children: [
          _buildSocialSidebar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool isDesktop = constraints.maxWidth > 950;
                  return Flex(
                    direction: isDesktop ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: isDesktop ? 2 : 0,
                        child: _buildMainInputCard(),
                      ),
                      const SizedBox(width: 24, height: 24),
                      Expanded(
                        flex: isDesktop ? 1 : 0,
                        child: _buildPreviewPanel(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI Components ---

  Widget _buildMainInputCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dynamic Grid Selection
          Wrap(
            spacing: 15,
            runSpacing: 15,
            children: _qrTypes.map((type) => _buildTypeTile(type)).toList(),
          ),
          const SizedBox(height: 40),
          Text("$_selectedType QR Code",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Dynamic Input Field
          TextField(
            controller: _inputController,
            onChanged: (val) => setState(() {}), // Refresh QR preview
            decoration: InputDecoration(
              hintText: "Enter your ${_selectedType.toLowerCase()} here...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 60),

          // Bottom Toggle Bar
          Row(
            children: [
              const Icon(Icons.cloud_upload_outlined, color: Colors.cyan),
              const SizedBox(width: 8),
              const Text("Upload any file", style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text("Scan tracking", style: TextStyle(color: Colors.grey[700])),
              Switch(
                value: _isTrackingEnabled,
                activeColor: Colors.cyan,
                onChanged: (val) => setState(() => _isTrackingEnabled = val),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTypeTile(Map<String, dynamic> type) {
    bool isSelected = _selectedType == type['label'];
    return InkWell(
      onTap: () => setState(() => _selectedType = type['label']),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Colors.cyan : Colors.transparent),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(type['icon'], size: 18, color: isSelected ? Colors.cyan : Colors.grey[600]),
            const SizedBox(width: 8),
            Text(type['label'],
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.cyan : Colors.black87
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          // Dynamic QR Code Preview
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: QrImageView(
              data: _inputController.text,
              version: QrVersions.auto,
              size: 200.0,
            ),
          ),
          const SizedBox(height: 20),

          // Dynamic Accordion Sections
          _buildAccordion("FRAME"),
          _buildAccordion("SHAPE & COLOR"),
          _buildAccordion("LOGO"),

          const SizedBox(height: 20),

          // Download Action
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {}, // Logic to save image
              icon: const Icon(Icons.download),
              label: const Text("DOWNLOAD JPG"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8BC34A),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccordion(String title) {
    bool isOpen = _expandedSection == title;
    return GestureDetector(
      onTap: () => setState(() => _expandedSection = isOpen ? "" : title),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(
                    color: isOpen ? Colors.cyan : Colors.grey[700],
                    fontWeight: FontWeight.bold
                )),
                Icon(isOpen ? Icons.expand_less : Icons.expand_more, color: Colors.grey),
              ],
            ),
            if (isOpen) ...[
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Customization options would appear here..."),
              )
            ]
          ],
        ),
      ),
    );
  }

  // Common UI Methods
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: const Text("QR Code Generator", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      actions: [
        TextButton(onPressed: () {}, child: const Text("Login")),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
            child: const Text("SIGN UP"),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialSidebar() {
    return Container(
      width: 50,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 20),
          _sidebarIcon(Icons.share, Colors.blue),
          _sidebarIcon(Icons.facebook, Colors.indigo),
          _sidebarIcon(Icons.camera_alt, Colors.red),
        ],
      ),
    );
  }

  Widget _sidebarIcon(IconData icon, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Icon(icon, color: color),
  );

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
    );
  }
}