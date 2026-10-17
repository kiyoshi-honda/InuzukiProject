CREATE TABLE game_room (
    id BIGINT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL
);

CREATE TABLE game_participant (
    room_id BIGINT NOT NULL,
    username VARCHAR(100) NOT NULL,
    started BOOLEAN NOT NULL DEFAULT FALSE,
    joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (room_id, username),
    FOREIGN KEY (room_id) REFERENCES game_room(id)
);

CREATE TABLE game_round (
    room_id BIGINT PRIMARY KEY,
    dog_hand VARCHAR(20),
    status VARCHAR(20) NOT NULL,
    FOREIGN KEY (room_id) REFERENCES game_room(id),
    CHECK (dog_hand IS NULL OR dog_hand IN ('ROCK', 'SCISSORS', 'PAPER')),
    CHECK (status IN ('WAITING', 'COMPLETE'))
);

CREATE TABLE game_round_participant (
    room_id BIGINT NOT NULL,
    username VARCHAR(100) NOT NULL,
    hand VARCHAR(20),
    PRIMARY KEY (room_id, username),
    FOREIGN KEY (room_id) REFERENCES game_round(room_id),
    FOREIGN KEY (room_id, username) REFERENCES game_participant(room_id, username),
    CHECK (hand IS NULL OR hand IN ('ROCK', 'SCISSORS', 'PAPER'))
);
