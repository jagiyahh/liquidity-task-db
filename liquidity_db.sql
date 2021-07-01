DROP TABLE IF EXISTS data_ads;
DROP TABLE IF EXISTS data_replies;
DROP TABLE IF EXISTS data_segmentation;
DROP TABLE IF EXISTS data_categories;

ALTER DATABASE d7uvk166abbjed SET DateStyle = 'german';

CREATE TABLE data_segmentation (
    user_id INTEGER NOT NULL PRIMARY KEY,
    segment VARCHAR(20)
);

CREATE TABLE data_categories (
    category_id INTEGER NOT NULL PRIMARY KEY,
    category_name VARCHAR(50)
);

CREATE TABLE data_ads (
    date DATE,
    user_id INTEGER REFERENCES data_segmentation(user_id),
    ad_id INTEGER NOT NULL PRIMARY KEY,
    category_id INTEGER REFERENCES data_categories(category_id),
    params VARCHAR (1000)
);

CREATE TABLE data_replies (
    date DATE,
    user_id INTEGER NOT NULL REFERENCES data_segmentation(user_id),
    ad_id INTEGER NOT NULL,
    mails INTEGER DEFAULT 0,
    phones INTEGER DEFAULT 0,
    PRIMARY KEY (date, user_id, ad_id)
);


-- liczba ogłoszeń użytkownika
SELECT COUNT(*) FROM data_ads WHERE user_id = 3661567;

-- liczba odpowiedzi dla konkretnych ogłoszeń
SELECT COUNT(*) FROM data_replies
WHERE ad_id IN (
            SELECT ad_id FROM data_ads
            WHERE user_id = 3661567)
GROUP BY ad_id
HAVING SUM(mails) > 0 OR SUM(phones) > 0;

-- liczba ogłoszeń przykładowego użytkownika, które otrzymały co najmniej jedną odpowiedź
SELECT COUNT(*) FROM (
            SELECT ad_id FROM data_replies
            WHERE ad_id IN (
                        SELECT ad_id FROM data_ads
                        WHERE user_id = 3661567)
            GROUP BY ad_id
            HAVING SUM(mails) > 0 OR SUM(phones) > 0)src;



-- funkcja licząca liquidity dla danego użytkownika
DROP FUNCTION IF EXISTS user_liquidity;

create function user_liquidity(usr int)
returns float
language plpgsql
as
$$
declare
    answered_ads integer;
    all_ads integer;
begin
   SELECT COUNT(*)
   INTO answered_ads
   FROM (
        SELECT ad_id FROM data_replies
        WHERE ad_id IN (
                SELECT ad_id FROM data_ads WHERE user_id = usr)
        GROUP BY ad_id
        having SUM(mails) > 0 or SUM(phones) > 0)src;

   SELECT COUNT(*)
   INTO all_ads
   FROM data_ads
   WHERE user_id = usr;

   IF all_ads = 0 THEN
    return NULL;
   ELSE
    return ROUND(1.0*answered_ads/all_ads*100,2);
    END IF;
end;
$$;

-- SELECT user_liquidity(3661567);

-- lista wszytkich użytkowników wraz z ich liquidity
-- data_segmentation jest najwygodniejszą tabelą do pobrania listy użytkowników, ponieważ tylko w niej sie nie powielają

SELECT user_id, user_liquidity(user_id) FROM data_segmentation

