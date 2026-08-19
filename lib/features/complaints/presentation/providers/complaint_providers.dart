import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/remote_complaint_repository.dart';
import '../../domain/models/complaint.dart';
import '../../domain/repositories/complaint_repository.dart';

final complaintRepositoryProvider = Provider<ComplaintRepository>(
  (ref) => RemoteComplaintRepository(ref.read(apiClientProvider)),
  name: 'complaintRepository',
);

final complaintsProvider = FutureProvider.autoDispose<List<Complaint>>((ref) {
  final repo = ref.watch(complaintRepositoryProvider);
  return repo.getComplaints();
}, name: 'complaints');
