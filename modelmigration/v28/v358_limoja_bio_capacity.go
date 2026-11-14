// Copyright 2026 The Gitea Authors (Limoja patch). All rights reserved.
// SPDX-License-Identifier: MIT

package v28

import (
	"context"

	"gitea.dev/modelmigration/base"
)

// WidenUserDescriptionToText — LIMOJA PATCH (bio-capacity): role prompts
// live in the Gitea bio; the stock varchar(255) is widened to TEXT so a
// 20K-word prompt stores and reads byte-complete through the API.
func WidenUserDescriptionToText(_ context.Context, x base.EngineMigration) error {
	_, err := x.Exec("ALTER TABLE \"user\" ALTER COLUMN description TYPE TEXT")
	return err
}
