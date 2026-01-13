import 'package:dartz/dartz.dart';
import 'package:quote_vault/core/error/failures.dart';
import 'package:quote_vault/core/usecase/usecase.dart';
import 'package:quote_vault/features/auth/domain/entities/user_entity.dart';
import 'package:quote_vault/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) {
    return repository.login(email: params.email, password: params.password);
  }
}

class LoginParams {
  final String email;
  final String password;
  LoginParams({required this.email, required this.password});
}

class SignUpUseCase implements UseCase<UserEntity, SignUpParams> {
  final AuthRepository repository;
  SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) {
    return repository.signUp(
      email: params.email,
      password: params.password,
      name: params.name,
    );
  }
}

class SignUpParams {
  final String email;
  final String password;
  final String name;
  SignUpParams({
    required this.email,
    required this.password,
    required this.name,
  });
}

class LogoutUseCase implements UseCase<Unit, NoParams> {
  final AuthRepository repository;
  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) {
    return repository.logout();
  }
}
