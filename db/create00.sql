
-- CREATE DATABASE tasks;
CREATE EXTENSION "uuid-ossp";

CREATE TABLE members(
    id UUID NOT NULL DEFAULT uuid_generate_v1(),
    name TEXT NOT NULL,
    -- node TEXT NOT NULL DEFAULT '',
    -- at TIMESTAMP NOT NULL DEFAULT current_timestamp,
    PRIMARY KEY (id)
);
COMMENT ON TABLE members IS 'メンバー';
COMMENT ON COLUMN members.id IS 'ID';
COMMENT ON COLUMN members.name IS '名前';
-- COMMENT ON COLUMN members.node IS '組織階層など文字列で何とかする';
-- COMMENT ON COLUMN members.at IS '作成/更新のタイムスタンプ';


CREATE TABLE projects(
    id UUID NOT NULL DEFAULT uuid_generate_v1(),
    name TEXT NOT NULL,
    -- node TEXT NOT NULL DEFAULT '',
    -- start_at TIMESTAMP,
    -- end_at TIMESTAMP,
    -- price INTEGER,
    -- manday INTEGER,
    -- at TIMESTAMP NOT NULL DEFAULT current_timestamp,
    PRIMARY KEY (id)
);
COMMENT ON TABLE projects IS 'プロジェクト';
COMMENT ON COLUMN projects.id IS 'ID';
COMMENT ON COLUMN projects.name IS '名前';
-- COMMENT ON COLUMN projects.node IS '顧客/フェーズなど文字列で何とかする';
-- COMMENT ON COLUMN projects.start_at IS '予定開始日';
-- COMMENT ON COLUMN projects.end_at IS '予定終了日';
-- COMMENT ON COLUMN projects.price IS '見積金額';
-- COMMENT ON COLUMN projects.manday IS '見積工数';
-- COMMENT ON COLUMN projects.at IS '作成/更新のタイムスタンプ';


CREATE TABLE assigns(
    id UUID NOT NULL DEFAULT uuid_generate_v1(),
    projectid UUID NOT NULL,
    memberid UUID NOT NULL,
    -- node TEXT NOT NULL DEFAULT '',
    -- start_at TIMESTAMP,
    -- end_at TIMESTAMP,
    -- volume INTEGER,
    -- at TIMESTAMP NOT NULL DEFAULT current_timestamp,
    PRIMARY KEY (id),
    FOREIGN KEY (projectid) REFERENCES projects(id),
    FOREIGN KEY (memberid) REFERENCES members(id)
);
COMMENT ON TABLE assigns IS 'アサイン';
COMMENT ON COLUMN assigns.id IS 'ID';
COMMENT ON COLUMN assigns.projectid IS 'プロジェクトID';
COMMENT ON COLUMN assigns.memberid IS 'メンバーID';
-- COMMENT ON COLUMN assigns.node IS '作業内容など文字列で何とかする';
-- COMMENT ON COLUMN assigns.start_at IS '予定開始日';
-- COMMENT ON COLUMN assigns.end_at IS '予定終了日';
-- COMMENT ON COLUMN assigns.volume IS '稼働割合（0～100%）';
-- COMMENT ON COLUMN assigns.at IS '作成/更新のタイムスタンプ';

--
-- Data
--
INSERT INTO members(name) VALUES('taro'),('jiro'),('sabu');
INSERT INTO projects(name) VALUES('dev-a'),('dev-b');
INSERT INTO assigns(projectid, memberid) VALUES(
    (SELECT id FROM projects WHERE name='dev-a'),
    (SELECT id FROM members WHERE name='taro')
);
INSERT INTO assigns(projectid, memberid) VALUES(
    (SELECT id FROM projects WHERE name='dev-a'),
    (SELECT id FROM members WHERE name='jiro')
);
INSERT INTO assigns(projectid, memberid) VALUES(
    (SELECT id FROM projects WHERE name='dev-b'),
    (SELECT id FROM members WHERE name='jiro')
);
INSERT INTO assigns(projectid, memberid) VALUES(
    (SELECT id FROM projects WHERE name='dev-b'),
    (SELECT id FROM members WHERE name='sabu')
);
