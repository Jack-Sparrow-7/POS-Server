import 'dart:developer';

import 'package:loxia/loxia.dart';
import 'package:pos_backend/config/env.dart';
import 'package:pos_backend/models/category/category.dart';
import 'package:pos_backend/models/counter/counter.dart';
import 'package:pos_backend/models/customer/customer.dart';
import 'package:pos_backend/models/merchant/merchant.dart';
import 'package:pos_backend/models/product/product.dart';
import 'package:pos_backend/models/stock/stock.dart';
import 'package:pos_backend/models/store/store.dart';
import 'package:pos_backend/models/terminal/terminal.dart';
import 'package:postgres/postgres.dart';

/// Shared application data source instance.
late final DataSource dataSource;

/// Initializes the PostgreSQL data source using environment configuration.
Future<void> initDatabase() async {
  dataSource = DataSource(
    PostgresDataSourceOptions.connect(
      host: Env.dbHost,
      port: Env.dbPort,
      database: Env.dbName,
      username: Env.dbUser,
      password: Env.dbPassword,
      entities: [
        $MerchantEntityDescriptor,
        $CustomerEntityDescriptor,
        $StoreEntityDescriptor,
        $TerminalEntityDescriptor,
        $CategoryEntityDescriptor,
        $CounterEntityDescriptor,
        $ProductEntityDescriptor,
        $StockEntityDescriptor,
      ],
      settings: ConnectionSettings(
        timeZone: 'UTC',
        sslMode: Env.isProd ? SslMode.require : SslMode.disable,
      ),
    ),
  );

  await dataSource.init();

  log('Database Initialized.');
}
