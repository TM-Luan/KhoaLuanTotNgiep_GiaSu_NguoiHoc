import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/data/models/notification_model.dart';
import 'notification_event.dart';
import 'notification_state.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;

  NotificationBloc(this._repository) : super(NotificationInitial()) {
    on<LoadNotifications>((event, emit) async {
      emit(NotificationLoading());
      try {
        final data = await _repository.getNotifications();
        emit(NotificationLoaded(data));
      } catch (e) {
        emit(NotificationError(e.toString()));
      }
    });

    on<MarkAsRead>((event, emit) async {
      if (state is NotificationLoaded) {
        final currentList = (state as NotificationLoaded).notifications;
        
        // Cập nhật UI ngay lập tức (Optimistic UI update)
        final updatedList = currentList.map((n) {
          if (n.id == event.id) {
            return NotificationModel(
              id: n.id, userId: n.userId, title: n.title, 
              message: n.message, type: n.type, relatedId: n.relatedId,
              isRead: true, createdAt: n.createdAt
            );
          }
          return n;
        }).toList();
        
        emit(NotificationLoaded(updatedList));

        // Gọi API server
        await _repository.markAsRead(event.id);
      }
    });
  }
}