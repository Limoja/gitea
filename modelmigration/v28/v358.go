// Copyright 2026 The Gitea Authors. All rights reserved.
// SPDX-License-Identifier: MIT

package v28

import (
	"context"

	"gitea.dev/modelmigration/base"

	"xorm.io/xorm/schemas"
)

// WidenUserDescription — raise the user profile description (the account Bio)
// from varchar(255) to varchar(65535) so an agent's full role prompt can live
// on the account Bio.
func WidenUserDescription(_ context.Context, x base.EngineMigration) error {
	switch x.Dialect().URI().DBType {
	case schemas.POSTGRES:
		if _, err := x.Exec("ALTER TABLE user ALTER COLUMN description TYPE varchar(65535)"); err != nil {
			return err
		}
	case schemas.MYSQL:
		if _, err := x.Exec("ALTER TABLE user MODIFY description varchar(65535)"); err != nil {
			return err
		}
	case schemas.MSSQL:
		if _, err := x.Exec("ALTER TABLE user ALTER COLUMN description varchar(65535)"); err != nil {
			return err
		}
	}
	return nil
}
