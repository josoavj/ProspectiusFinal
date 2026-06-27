import '../../services/mysql_service.dart';
import '../../data/repositories/prospect_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/repositories/document_repository_impl.dart';
import '../../data/repositories/custom_field_repository_impl.dart';
import '../../domain/repositories/i_prospect_repository.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_task_repository.dart';
import '../../domain/repositories/i_document_repository.dart';
import '../../domain/repositories/i_custom_field_repository.dart';
import '../../services/secure_storage_service.dart';
import '../../services/logging_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Services
  late final MySQLService mysqlService;
  late final SecureStorageService secureStorage;
  late final LoggingService loggingService;
  
  // Repositories
  late final IProspectRepository prospectRepository;
  late final IAuthRepository authRepository;
  late final ITaskRepository taskRepository;
  late final IDocumentRepository documentRepository;
  late final ICustomFieldRepository customFieldRepository;

  Future<void> setup() async {
    loggingService = LoggingService();
    await loggingService.initialize();
    
    secureStorage = SecureStorageService();
    mysqlService = MySQLService();
    
    // Initialisation des dépôts
    prospectRepository = ProspectRepositoryImpl(mysqlService);
    authRepository = AuthRepositoryImpl(mysqlService);
    taskRepository = TaskRepositoryImpl(mysqlService);
    documentRepository = DocumentRepositoryImpl(mysqlService);
    customFieldRepository = CustomFieldRepositoryImpl(mysqlService);
  }
}

final sl = ServiceLocator();
