import 'dart:async';

/// Service để quản lý thông báo cập nhật toàn cục
/// Dùng để thông báo khi có thay đổi về proposal/class 
/// để các trang liên quan có thể tự động refresh
class GlobalNotificationService {
  static final GlobalNotificationService _instance = GlobalNotificationService._internal();
  factory GlobalNotificationService() => _instance;
  GlobalNotificationService._internal();

  // Stream để thông báo cập nhật proposal
  final StreamController<ProposalUpdateEvent> _proposalUpdateController = 
      StreamController<ProposalUpdateEvent>.broadcast();

  // Stream để thông báo cập nhật lớp học
  final StreamController<ClassUpdateEvent> _classUpdateController = 
      StreamController<ClassUpdateEvent>.broadcast();

  // Getter cho stream
  Stream<ProposalUpdateEvent> get proposalUpdateStream => _proposalUpdateController.stream;
  Stream<ClassUpdateEvent> get classUpdateStream => _classUpdateController.stream;

  /// Thông báo proposal đã được chấp nhận
  void notifyProposalAccepted({
    required int proposalId,
    required int classId,
    required int tutorId,
  }) {
    _proposalUpdateController.add(ProposalUpdateEvent(
      type: ProposalUpdateType.accepted,
      proposalId: proposalId,
      classId: classId,
      tutorId: tutorId,
    ));
  }

  /// Thông báo proposal đã bị từ chối
  void notifyProposalRejected({
    required int proposalId,
    required int classId,
    required int tutorId,
  }) {
    _proposalUpdateController.add(ProposalUpdateEvent(
      type: ProposalUpdateType.rejected,
      proposalId: proposalId,
      classId: classId,
      tutorId: tutorId,
    ));
  }

  /// Thông báo proposal đã bị hủy
  void notifyProposalCancelled({
    required int proposalId,
    required int classId,
    required int tutorId,
  }) {
    _proposalUpdateController.add(ProposalUpdateEvent(
      type: ProposalUpdateType.cancelled,
      proposalId: proposalId,
      classId: classId,
      tutorId: tutorId,
    ));
  }

  /// Thông báo lớp học đã được cập nhật
  void notifyClassUpdated({
    required int classId,
    required ClassUpdateType type,
  }) {
    _classUpdateController.add(ClassUpdateEvent(
      classId: classId,
      type: type,
    ));
  }

  /// Dispose tất cả stream
  void dispose() {
    _proposalUpdateController.close();
    _classUpdateController.close();
  }
}

/// Event cho cập nhật proposal
class ProposalUpdateEvent {
  final ProposalUpdateType type;
  final int proposalId;
  final int classId;
  final int tutorId;

  ProposalUpdateEvent({
    required this.type,
    required this.proposalId,
    required this.classId,
    required this.tutorId,
  });
}

enum ProposalUpdateType {
  accepted,
  rejected,
  cancelled,
}

/// Event cho cập nhật lớp học
class ClassUpdateEvent {
  final int classId;
  final ClassUpdateType type;

  ClassUpdateEvent({
    required this.classId,
    required this.type,
  });
}

enum ClassUpdateType {
  statusChanged,
  tutorAssigned,
  proposalCountChanged,
}