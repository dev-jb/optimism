package backend

import (
	"errors"
	"fmt"
	"io"
	"math"
)

// Resume prepares the given LogStore to resume recording events.
// It returns the block number of the last block that is guaranteed to have been fully recorded to the database
// and rewinds the database to ensure it can resume recording from the first log of the next block.
func Resume(logDB LogStore) (uint64, error) {
	// Get the last checkpoint that was written then Rewind the db
	// to the block prior to that block and start from there.
	// Guarantees we will always roll back at least one block
	// so we know we're always starting from a fully written block.
	checkPointBlock, _, err := logDB.ClosestBlockInfo(math.MaxUint64)
	if errors.Is(err, io.EOF) {
		// No blocks recorded in the database, start from genesis
		return 0, nil
	} else if err != nil {
		return 0, fmt.Errorf("failed to get block from checkpoint: %w", err)
	}
	if checkPointBlock == 0 {
		return 0, nil
	}
	block := checkPointBlock - 1
	err = logDB.Rewind(block)
	if err != nil {
		return 0, fmt.Errorf("failed to 'Rewind' the database: %w", err)
	}
	return block, nil
}
