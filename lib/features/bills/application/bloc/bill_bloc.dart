import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/group_model.dart';
import '../../domain/models/contact_model.dart';
import '../../domain/repositories/group_repository.dart';

part 'bill_event.dart';
part 'bill_state.dart';

class BillBloc extends Bloc<BillEvent, BillState> {
  final GroupRepository _groupRepository;

  BillBloc(this._groupRepository) : super(BillInitial()) {
    on<LoadUserGroups>(_onLoadUserGroups);
    on<LoadGroupsByMonth>(_onLoadGroupsByMonth);
    on<CreateGroup>(_onCreateGroup);
    on<UpdateGroup>(_onUpdateGroup);
    on<DeleteGroup>(_onDeleteGroup);
    on<LoadContacts>(_onLoadContacts);
    on<LoadRegisteredContacts>(_onLoadRegisteredContacts);
    on<AddMemberToGroup>(_onAddMemberToGroup);
    on<RemoveMemberFromGroup>(_onRemoveMemberFromGroup);
  }

  Future<void> _onLoadUserGroups(
      LoadUserGroups event, Emitter<BillState> emit) async {
    emit(BillLoading());

    await emit.forEach(
      _groupRepository.getUserGroups(event.userPhone),
      onData: (groups) {
        // Group by month for easy access
        final groupsByMonth = <int, List<GroupModel>>{};
        for (final group in groups) {
          if (!groupsByMonth.containsKey(group.month)) {
            groupsByMonth[group.month] = [];
          }
          groupsByMonth[group.month]!.add(group);
        }

        return GroupsLoaded(groups: groups, groupsByMonth: groupsByMonth);
      },
      onError: (error, stackTrace) => BillError(error.toString()),
    );
  }

  Future<void> _onLoadGroupsByMonth(
      LoadGroupsByMonth event, Emitter<BillState> emit) async {
    emit(BillLoading());

    final result = await _groupRepository.getGroupsByMonth(
      event.userPhone,
      event.month,
      event.year,
    );

    result.fold(
      (failure) => emit(BillError(failure.message)),
      (groups) => emit(GroupsLoadedByMonth(
        groups: groups,
        month: event.month,
        year: event.year,
      )),
    );
  }

  Future<void> _onCreateGroup(
      CreateGroup event, Emitter<BillState> emit) async {
    emit(BillLoading());

    final result = await _groupRepository.createGroup(
      name: event.name,
      description: event.description,
      creatorId: event.creatorId,
      creatorPhone: event.creatorPhone,
      members: event.members,
      month: event.month,
      year: event.year,
    );

    result.fold(
      (failure) => emit(BillError(failure.message)),
      (group) => emit(GroupCreated(group)),
    );
  }

  Future<void> _onUpdateGroup(
      UpdateGroup event, Emitter<BillState> emit) async {
    emit(BillLoading());

    final result = await _groupRepository.updateGroup(event.group);

    result.fold(
      (failure) => emit(BillError(failure.message)),
      (group) => emit(GroupUpdated(group)),
    );
  }

  Future<void> _onDeleteGroup(
      DeleteGroup event, Emitter<BillState> emit) async {
    emit(BillLoading());

    final result =
        await _groupRepository.deleteGroup(event.groupId, event.userId);

    result.fold(
      (failure) => emit(BillError(failure.message)),
      (_) => emit(GroupDeleted(event.groupId)),
    );
  }

  Future<void> _onLoadContacts(
      LoadContacts event, Emitter<BillState> emit) async {
    emit(BillLoading());

    final result = await _groupRepository.getPhoneContacts();

    result.fold(
      (failure) => emit(BillError(failure.message)),
      (contacts) => emit(ContactsLoaded(
        contacts: contacts,
        registeredContacts: [],
      )),
    );
  }

  Future<void> _onLoadRegisteredContacts(
      LoadRegisteredContacts event, Emitter<BillState> emit) async {
    emit(BillLoading());

    final result =
        await _groupRepository.getRegisteredContacts(event.phoneNumbers);

    result.fold(
      (failure) => emit(BillError(failure.message)),
      (registeredContacts) {
        if (state is ContactsLoaded) {
          final currentState = state as ContactsLoaded;
          emit(ContactsLoaded(
            contacts: currentState.contacts,
            registeredContacts: registeredContacts,
          ));
        } else {
          emit(ContactsLoaded(
            contacts: [],
            registeredContacts: registeredContacts,
          ));
        }
      },
    );
  }

  Future<void> _onAddMemberToGroup(
      AddMemberToGroup event, Emitter<BillState> emit) async {
    emit(BillLoading());

    final result =
        await _groupRepository.addMemberToGroup(event.groupId, event.member);

    result.fold(
      (failure) => emit(BillError(failure.message)),
      (_) => emit(MemberAdded(event.groupId, event.member)),
    );
  }

  Future<void> _onRemoveMemberFromGroup(
      RemoveMemberFromGroup event, Emitter<BillState> emit) async {
    emit(BillLoading());

    final result = await _groupRepository.removeMemberFromGroup(
        event.groupId, event.memberPhone);

    result.fold(
      (failure) => emit(BillError(failure.message)),
      (_) => emit(MemberRemoved(event.groupId, event.memberPhone)),
    );
  }
}
