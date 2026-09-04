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
