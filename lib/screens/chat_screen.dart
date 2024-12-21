import 'dart:io';
import 'dart:typed_data';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = <ChatMessage>[];

  ChatUser currentUser = ChatUser(id: "user", firstName: "User");
  ChatUser geminiUser = ChatUser(
    id: "bot",
    firstName: "Ai Helper",
    profileImage:
        "https://seeklogo.com/images/G/google-gemini-logo-A5787B2669-seeklogo.com.png",
  );

  @override
  void initState() {
    messages.add(
      ChatMessage(
        text: "আসসালামু আলাইকুম। আমি আপনাকে কিভাবে সাহায্য করতে পারি?",
        user: ChatUser(id: 'bot', firstName: "AI"),
        createdAt: DateTime.now(),
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat With AI"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return DashChat(
      currentUser: currentUser,
      onSend: _sendMessage,
      messages: messages,
      inputOptions: InputOptions(leading: [
        IconButton(
          onPressed: sendMediaMessage,
          icon: const Icon(Icons.image),
        ),
      ]),
    );
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });
    try {
      String question = chatMessage.text;
      List<Uint8List>? images;
      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [
          File(chatMessage.medias!.first.url).readAsBytesSync(),
        ];
      }
      gemini.streamGenerateContent(question, images: images).listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);

          String response = event.content?.parts?.fold(
                  "",
                  (previous, current) =>
                      "$previous ${(current as TextPart).text}") ??
              "";
          lastMessage.text += response;
          setState(
            () {
              messages = [lastMessage!, ...messages];
            },
          );
        } else {
          String response = event.content?.parts?.fold(
                  "",
                  (previous, current) =>
                      "$previous ${(current as TextPart).text}") ??
              "";
          ChatMessage message = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: response,
          );
          setState(() {
            messages = [message, ...messages];
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void sendMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      ChatMessage message = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: " Describe the picture",
        medias: [
          ChatMedia(url: file.path, fileName: "", type: MediaType.image),
        ],
      );

      _sendMessage(message);
    }
  }
}

//=============================

// import 'dart:io';
//
// import 'package:challenge_2/constant.dart';
// import 'package:dash_chat_2/dash_chat_2.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_gemini/flutter_gemini.dart';
// import 'package:image_picker/image_picker.dart';
//
// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final Gemini gemini = Gemini.instance;
//   final ImagePicker _picker = ImagePicker();
//   final Dio _dio = Dio();
//
//   List<ChatMessage> messages = <ChatMessage>[];
//   File? selectedImage;
//
//   ChatUser currentUser = ChatUser(id: "user", firstName: "User");
//   ChatUser geminiUser = ChatUser(
//     id: "bot",
//     firstName: "Smart Aggro",
//     profileImage:
//         "https://seeklogo.com/images/G/google-gemini-logo-A5787B2669-seeklogo.com.png",
//   );
//
//   @override
//   void initState() {
//     messages.add(
//       ChatMessage(
//         text: "আসসালামু আলাইকুম। আমি আপনাকে কিভাবে সাহায্য করতে পারি?",
//         user: ChatUser(id: 'bot', firstName: "AI"),
//         createdAt: DateTime.now(),
//       ),
//     );
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Chat With AI"),
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         scrolledUnderElevation: 0,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: DashChat(
//               currentUser: currentUser,
//               onSend: _sendMessage,
//               messages: messages,
//               inputOptions: InputOptions(
//                 leading: [
//                   IconButton(
//                     icon: const Icon(Icons.image),
//                     onPressed: _pickImage,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (selectedImage != null)
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   Image.file(
//                     selectedImage!,
//                     width: 50,
//                     height: 50,
//                     fit: BoxFit.cover,
//                   ),
//                   const SizedBox(width: 8),
//                   const Text("Image selected"),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _pickImage() async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       setState(() {
//         selectedImage = File(image.path);
//       });
//     }
//   }
//
//   void _sendMessage(ChatMessage chatMessage) {
//     setState(() {
//       messages = [chatMessage, ...messages];
//     });
//
//     try {
//       String question = chatMessage.text;
//
//       if (selectedImage != null) {
//         // Send both query and image
//         _sendImageWithQuery(selectedImage!, question);
//       } else {
//         // Send text query only
//         gemini.streamGenerateContent(question).listen((event) {
//           String response = event.content?.parts?.fold(
//                   "",
//                   (previous, current) =>
//                       "$previous ${(current as TextPart).text}") ??
//               "";
//           ChatMessage aiResponse = ChatMessage(
//             user: geminiUser,
//             createdAt: DateTime.now(),
//             text: response,
//           );
//           setState(() {
//             messages = [aiResponse, ...messages];
//           });
//         });
//       }
//     } catch (e) {
//       ChatMessage errorResponse = ChatMessage(
//         user: geminiUser,
//         createdAt: DateTime.now(),
//         text: "Sorry, an error occurred: $e",
//       );
//       setState(() {
//         messages = [errorResponse, ...messages];
//       });
//     } finally {
//       setState(() {
//         selectedImage = null; // Reset selected image after sending
//       });
//     }
//   }
//
//   Future<void> _sendImageWithQuery(File imageFile, String query) async {
//     try {
//       final dio = Dio();
//
//       // Prepare the form data
//       final formData = FormData.fromMap({
//         'query': query, // Add the user's query
//         'image':
//             await MultipartFile.fromFile(imageFile.path), // Attach the image
//       });
//
//       // Make the API call
//       final response = await dio.post(
//         'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=${Constant.geminiApiKey}',
//         data: formData,
//         options: Options(
//           headers: {
//             'Content-Type': 'multipart/form-data',
//           },
//         ),
//       );
//
//       if (response.statusCode == 200) {
//         // Parse the response
//         String result = response.data['result'] ?? 'No result found.';
//         ChatMessage aiResponse = ChatMessage(
//           user: geminiUser,
//           createdAt: DateTime.now(),
//           text: "Response: $result",
//         );
//
//         setState(() {
//           messages = [aiResponse, ...messages];
//         });
//       } else {
//         throw Exception('Error: ${response.statusCode}');
//       }
//     } catch (e) {
//       ChatMessage errorResponse = ChatMessage(
//         user: geminiUser,
//         createdAt: DateTime.now(),
//         text: "Sorry, I couldn't process the image. Error: $e",
//       );
//       setState(() {
//         messages = [errorResponse, ...messages];
//       });
//     }
//   }
// }
