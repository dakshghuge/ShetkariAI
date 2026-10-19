import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class Scheme {
  final String title;
  final String titleEn;
  final String description;
  final String descriptionEn;
  final String brief;
  final String briefEn;
  final String eligibility;
  final String documents;
  final String url;

  Scheme({
    required this.title,
    required this.titleEn,
    required this.description,
    required this.descriptionEn,
    required this.brief,
    required this.briefEn,
    required this.eligibility,
    required this.documents,
    required this.url,
  });
}

class SchemesScreen extends StatelessWidget {
  const SchemesScreen({super.key});

  static final List<Scheme> centralSchemes = [
    Scheme(
      title: 'प्रधानमंत्री किसान सन्मान निधी (PM-KISAN)',
      titleEn: 'PM-Kisan Samman Nidhi',
      description: 'शेतकऱ्यांना वार्षिक ६,००० रुपयांची थेट आर्थिक मदत.',
      descriptionEn: 'Direct financial assistance of ₹6,000 annually to farmers.',
      brief: 'ही केंद्र सरकारची १००% अनुदानावरील योजना आहे. यात २,००० रुपयांचे तीन हप्ते थेट शेतकऱ्यांच्या बँक खात्यात जमा केले जातात. देशातील सर्व अल्प आणि अत्यल्प भूधारक शेतकरी कुटुंबांना याचा लाभ मिळतो.',
      briefEn: 'This is a 100% Central Sector Scheme. Financial benefit of ₹6000 per year is released in three equal installments of ₹2000 directly into the bank accounts of the beneficiaries.',
      eligibility: 'सर्व शेतकरी कुटुंबे ज्यांच्या नावे शेतीयोग्य जमीन आहे.',
      documents: 'आधार कार्ड, बँक खाते, जमिनीचा सातबारा/८-अ उतारा.',
      url: 'https://pmkisan.gov.in/',
    ),
    Scheme(
      title: 'प्रधानमंत्री किसान मानधन योजना',
      titleEn: 'PM Kisan Maandhan Yojana',
      description: 'शेतकऱ्यांसाठी पेन्शन योजना (वयाच्या ६० वर्षांनंतर).',
      descriptionEn: 'Pension scheme for farmers (after 60 years of age).',
      brief: 'लहान आणि अत्यल्प भूधारक शेतकऱ्यांसाठी ही ऐच्छिक आणि अंशदायी पेन्शन योजना आहे. ६० वर्षे वय पूर्ण झाल्यावर शेतकऱ्याला दरमहा ३,००० रुपये पेन्शन मिळते.',
      briefEn: 'A voluntary and contributory pension scheme for small and marginal farmers. A fixed pension of ₹3,000/- is provided on attaining the age of 60 years.',
      eligibility: '१८ ते ४० वर्षे वयोगटातील अल्प व अत्यल्प भूधारक शेतकरी.',
      documents: 'आधार कार्ड, बँक पासबुक, मोबाईल नंबर.',
      url: 'https://maandhan.in/',
    ),
    Scheme(
      title: 'मृदा आरोग्य पत्रिका योजना',
      titleEn: 'Soil Health Card Scheme',
      description: 'जमिनीच्या सुपीकतेनुसार खतांच्या वापरासाठी मार्गदर्शन.',
      descriptionEn: 'Guidance on fertilizer use based on soil fertility.',
      brief: 'शेतकऱ्यांना त्यांच्या जमिनीतील पोषक तत्वांची स्थिती जाणून घेण्यास मदत होते. यामुळे जमिनीचा पोत सुधारतो आणि अनावश्यक खतांवरील खर्च वाचतो.',
      briefEn: 'Helps farmers to know the nutrient status of their soil and receive dosage recommendations for fertilizers to improve soil health and fertility.',
      eligibility: 'देशातील सर्व शेतकरी.',
      documents: 'जमिनीचा नमुना (माती परीक्षण केंद्रावर देणे).',
      url: 'https://www.soilhealth.dac.gov.in/',
    ),
    Scheme(
      title: 'कृषी पायाभूत सुविधा निधी',
      titleEn: 'Agriculture Infrastructure Fund',
      description: 'कापणीपश्चात व्यवस्थापनासाठी कर्जावर व्याज सवलत.',
      descriptionEn: 'Interest subvention on loans for post-harvest management.',
      brief: 'शीतगृहे, गोदामे आणि प्रक्रिया युनिट्स उभारण्यासाठी मध्यम-दीर्घकालीन कर्ज वित्तपुरवठा सुविधा. यात वर्षाला ३% व्याजात सवलत मिळते.',
      briefEn: 'A financing facility for investment in viable projects for post-harvest management infrastructure and community farming assets with 3% interest subvention per annum.',
      eligibility: 'शेतकरी, बचत गट, कृषी उद्योजक, स्टार्टअप्स.',
      documents: 'प्रकल्प अहवाल, पॅन कार्ड, आधार कार्ड, बँक तपशील.',
      url: 'https://agriinfra.dac.gov.in/',
    ),
  ];

  static final List<Scheme> maharashtraSchemes = [
    Scheme(
      title: 'नमो शेतकरी महासन्मान निधी योजना',
      titleEn: 'Namo Shetkari Mahasanman Nidhi Yojana',
      description: 'राज्य सरकारकडून ६,००० रुपयांची अतिरिक्त मदत.',
      descriptionEn: 'Additional ₹6,000 assistance from the State Government.',
      brief: 'केंद्र सरकारच्या PM-KISAN योजनेला पूरक म्हणून महाराष्ट्र सरकारने ही योजना सुरू केली आहे. आता राज्यातील शेतकऱ्यांना वर्षाला एकूण १२,००० रुपये (६००० केंद्र + ६००० राज्य) मिळतात.',
      briefEn: 'Launched by the Maharashtra Govt to supplement PM-KISAN. Farmers in Maharashtra now receive a total of ₹12,000 per year.',
      eligibility: 'PM-KISAN योजनेचे सर्व पात्र लाभार्थी.',
      documents: 'PM-KISAN नोंदणी, बँक खाते (आधार लिंक).',
      url: 'https://nsmny.mahait.org/',
    ),
    Scheme(
      title: 'मागेल त्याला शेततळे योजना',
      titleEn: 'Magel Tyala Shettale Yojana',
      description: 'शेततळ्यासाठी ५०,००० रुपयांपर्यंतचे अनुदान.',
      descriptionEn: 'Subsidy up to ₹50,000 for farm ponds.',
      brief: 'शेतकऱ्याला स्वतःच्या शेतात पाणी साठवण्यासाठी शेततळे खोदता यावे यासाठी हे अनुदान दिले जाते. यामुळे दुष्काळी काळात पिकांना पाणी देता येते.',
      briefEn: 'Provides permanent source of water to the crops during dry spells. Farmers get subsidy for constructing farm ponds on their own land.',
      eligibility: 'किमान ०.४० हेक्टर जमीन असलेला शेतकरी.',
      documents: '७/१२ उतारा, ८-अ उतारा, जातीचा दाखला (आवश्यक असल्यास).',
      url: 'https://mahadbt.maharashtra.gov.in/',
    ),
    Scheme(
      title: 'गोपीनाथ मुंडे शेतकरी अपघात सुरक्षा सानुग्रह अनुदान योजना',
      titleEn: 'Gopinath Munde Shetkari Apaghat Vima',
      description: 'अपघाती मृत्यू किंवा अपंगत्व आल्यास २ लाखांपर्यंत मदत.',
      descriptionEn: 'Assistance up to ₹2 lakhs in case of accidental death or disability.',
      brief: 'शेती काम करताना किंवा नैसर्गिक आपत्तीमुळे अपघात झाल्यास शेतकऱ्याच्या कुटुंबाला आर्थिक आधार दिला जातो. मृत्यू झाल्यास २ लाख रुपये मिळतात.',
      briefEn: 'Provides financial security to the families of farmers in case of accidental death or permanent disability while performing farming tasks.',
      eligibility: '१० ते ७५ वयोगटातील महसूल अभिलेखात नोंद असलेला शेतकरी.',
      documents: 'अपघात अहवाल, मृत्यू दाखला, ७/१२ उतारा, वारस नोंद.',
      url: 'https://krishi.maharashtra.gov.in/',
    ),
    Scheme(
      title: 'छत्रपती शिवाजी महाराज शेतकरी सन्मान योजना',
      titleEn: 'CSMSSY (Loan Waiver)',
      description: 'थकबाकीदार शेतकऱ्यांसाठी कर्जमाफी योजना.',
      descriptionEn: 'Loan waiver scheme for defaulting farmers.',
      brief: 'ज्या शेतकऱ्यांचे पीक कर्ज थकले आहे, अशा शेतकऱ्यांना दीड लाखांपर्यंत कर्जमाफी दिली जाते. नियमित कर्ज फेडणाऱ्यांना प्रोत्साहनपर लाभ दिला जातो.',
      briefEn: 'Addresses agrarian distress by waiving crop loans up to ₹1.5 lakh for farmers and providing incentive benefits to those who repay regularly.',
      eligibility: 'थकबाकीदार शेतकरी (विशिष्ट निकषांनुसार).',
      documents: 'आधार कार्ड, बँक खाते तपशील, कर्ज पासबुक.',
      url: 'https://csmssy.in/',
    ),
  ];

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('शेतकरी सरकारी योजना', style: GoogleFonts.mukta(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.orange.shade400,
            tabs: const [
              Tab(text: 'केंद्र सरकार (Central)'),
              Tab(text: 'राज्य सरकार (State)'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSchemeList(centralSchemes),
            _buildSchemeList(maharashtraSchemes),
          ],
        ),
      ),
    );
  }

  Widget _buildSchemeList(List<Scheme> schemes) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: schemes.length,
      itemBuilder: (context, index) {
        final scheme = schemes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            title: Text(scheme.title, style: GoogleFonts.mukta(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green.shade900)),
            subtitle: Text(scheme.description, style: GoogleFonts.mukta(color: Colors.grey.shade700)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection('योजनेची माहिती (Brief)', scheme.brief),
                    _buildDetailSection('पात्रता (Eligibility)', scheme.eligibility),
                    _buildDetailSection('आवश्यक कागदपत्रे (Documents)', scheme.documents),
                    const Divider(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _launchUrl(scheme.url),
                        icon: const Icon(Icons.open_in_new),
                        label: Text('येथून अर्ज करा (Apply Now)', style: GoogleFonts.mukta(fontWeight: FontWeight.bold, fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(String label, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.mukta(fontWeight: FontWeight.bold, color: Colors.green.shade700, fontSize: 16)),
          Text(content, style: GoogleFonts.mukta(fontSize: 15)),
        ],
      ),
    );
  }
}
