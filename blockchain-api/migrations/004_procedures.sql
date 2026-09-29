
CREATE OR REPLACE PROCEDURE mine_block(
    p_miner_address  TEXT,
    p_index          INTEGER,
    p_previous_hash  TEXT,
    p_hash           TEXT,
    p_nonce          BIGINT,
    p_difficulty     INTEGER,
    p_reward_amount  NUMERIC,
    p_reward_tx_hash TEXT,
    INOUT p_block_id UUID DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
-- creating the block
    INSERT INTO blocks (index, previous_hash, hash, nonce, difficulty, miner_address)
    VALUES (p_index, p_previous_hash, p_hash, p_nonce, p_difficulty, p_miner_address)
    RETURNING id INTO p_block_id;

-- existing transaction
    UPDATE transactions
    SET status = 'confirmed', block_id = p_block_id, confirmed_at = now()
    WHERE status = 'pending';

    -- miners own transaction
    INSERT INTO transactions (
        tx_hash, from_address, to_address, amount, signature, status, block_id, confirmed_at
    ) VALUES (
        p_reward_tx_hash, NULL, p_miner_address, p_reward_amount, NULL, 'confirmed', p_block_id, now()
    );
END;
$$;
