INSERT INTO public.individual
(uuid, address_id, observations, version, date_of_birth, date_of_birth_verified, gender_id, registration_date,
 organisation_id, first_name, last_name, is_voided, audit_id, facility_id, registration_location,
 subject_type_id, legacy_id, created_by_id, last_modified_by_id, created_date_time, last_modified_date_time,
 sync_concept_1_value, sync_concept_2_value, profile_picture, middle_name, manual_update_history, sync_disabled,
 sync_disabled_date_time)
select uuid_generate_v4(), temp.address_id, '{}', 0, null, false,
       null, now()::date, 391, temp.title, null, false,
       create_audit(), null, null, 1470, null,
       9820, 9820, temp.custom_timestamp
        , temp.custom_timestamp, null,
       null, null, null, '#10|Insert villages not created',
       false, null
from (
         select distinct on (i.address_id, address_level.title)
             i.address_id, address_level.title, current_timestamp + (random() * 1000 * interval '1 millisecond') custom_timestamp
         from address_level join individual i on address_level.id = i.address_id
         where subject_type_id in (1099, 1100) and i.address_id not in
             (select address_id from individual where subject_type_id=1470)) temp; -- 3917


INSERT INTO public.group_subject
(uuid, group_subject_id, member_subject_id, group_role_id, membership_start_date, membership_end_date, organisation_id,
 audit_id, is_voided, version, created_by_id, last_modified_by_id, created_date_time, last_modified_date_time,
 member_subject_address_id, group_subject_address_id, group_subject_sync_concept_1_value,
 group_subject_sync_concept_2_value, sync_disabled, sync_disabled_date_time)
select uuid_generate_v4(), temp.group_id, temp.member_id, 824, temp.custom_timestamp,
       null, 391, create_audit(), false, 0, 9820,
       9820, temp.custom_timestamp, temp.custom_timestamp, temp.address_id, temp.address_id,
       null, null, false, null
from (select da.id member_id, v.id group_id, da.address_id,
             current_timestamp + (random() * 1000 * interval '1 millisecond') custom_timestamp
      from individual da join individual v on da.address_id = v.address_id
      where da.subject_type_id in (1100) and v.subject_type_id=1470 and da.id not in (
          select member_subject_id from group_subject where is_voided=false and membership_end_date is not null
      ) ) temp;

INSERT INTO public.group_subject
(uuid, group_subject_id, member_subject_id, group_role_id, membership_start_date, membership_end_date, organisation_id,
 audit_id, is_voided, version, created_by_id, last_modified_by_id, created_date_time, last_modified_date_time,
 member_subject_address_id, group_subject_address_id, group_subject_sync_concept_1_value,
 group_subject_sync_concept_2_value, sync_disabled, sync_disabled_date_time)
select uuid_generate_v4(), temp.group_id, temp.member_id, 825, temp.custom_timestamp,
       null, 391, create_audit(), false, 0, 9820,
       9820, temp.custom_timestamp, temp.custom_timestamp, temp.address_id, temp.address_id,
       null, null, false, null
from (select da.id member_id, v.id group_id, da.address_id,
             current_timestamp + (random() * 1000 * interval '1 millisecond') custom_timestamp
      from individual da join individual v on da.address_id = v.address_id
      where da.subject_type_id in (1099) and v.subject_type_id=1470 and da.id not in (
          select member_subject_id from group_subject where is_voided=false and membership_end_date is not null
      ) ) temp;


update group_subject set is_voided=true,
                         last_modified_date_time=current_timestamp + (random() * 1000 * interval '1 millisecond'),
                         last_modified_by_id=9820
where created_by_id !=9820; -- This is because in above instead of membership_end_date is not null should ve been null

-- To not insert other villages
update individual set is_voided=true,
                      last_modified_date_time=current_timestamp + (random() * 1000 * interval '1 millisecond'),
                      last_modified_by_id=9820,
                      manual_update_history='#10|Voided Other villages'
where first_name='Other' and created_by_id=9820 and subject_type_id=1470;


select * from individual join address_level
                              on individual.address_id = address_level.id
where title='Other' and individual.created_by_id=9820 and individual.is_voided=false;
-- 0

-- To not to add to Other villages
update group_subject
set is_voided=true,
    last_modified_date_time=current_timestamp + (random() * 1000 * interval '1 millisecond'),
    last_modified_by_id=9820
where id in (
    select group_subject.id from group_subject join address_level on group_subject.group_subject_address_id = address_level.id
    where address_level.title = 'Other' and group_subject.created_by_id=9820);

-- Verifying if all working

select distinct on (i.address_id, address_level.title)
    i.address_id, address_level.title, current_timestamp + (random() * 1000 * interval '1 millisecond') custom_timestamp
from address_level join individual i on address_level.id = i.address_id
where subject_type_id in (1099, 1100) and i.address_id not in
    (select address_id from individual where subject_type_id=1470) and
    address_level.title = 'Other';
--- 0 rows

select da.id member_id, v.id group_id, da.address_id,
       current_timestamp + (random() * 1000 * interval '1 millisecond') custom_timestamp
from individual da join individual v on da.address_id = v.address_id
                   join address_level on address_level.id = da.address_id
where da.subject_type_id in (1099) and v.subject_type_id=1470 and da.id not in (
    select member_subject_id from group_subject where is_voided=false and membership_end_date is null
) and address_level.title !='Other';
-- 1 row, now 0
select da.id member_id, v.id group_id, da.address_id,
       current_timestamp + (random() * 1000 * interval '1 millisecond') custom_timestamp
from individual da join individual v on da.address_id = v.address_id
                   join address_level on address_level.id = da.address_id
where da.subject_type_id in (1100) and v.subject_type_id=1470 and da.id not in (
    select member_subject_id from group_subject where is_voided=false and membership_end_date is null
) and address_level.title !='Other';
-- 6 rows, now 0

INSERT INTO public.group_subject
(uuid, group_subject_id, member_subject_id, group_role_id, membership_start_date, membership_end_date, organisation_id,
 audit_id, is_voided, version, created_by_id, last_modified_by_id, created_date_time, last_modified_date_time,
 member_subject_address_id, group_subject_address_id, group_subject_sync_concept_1_value,
 group_subject_sync_concept_2_value, sync_disabled, sync_disabled_date_time)
select uuid_generate_v4(), temp.group_id, temp.member_id, 824, temp.custom_timestamp,
       null, 391, create_audit(), false, 0, 9820,
       9820, temp.custom_timestamp, temp.custom_timestamp, temp.address_id, temp.address_id,
       null, null, false, null
from (select da.id member_id, v.id group_id, da.address_id,
             current_timestamp + (random() * 1000 * interval '1 millisecond') custom_timestamp
      from individual da join individual v on da.address_id = v.address_id
                         join address_level on address_level.id = da.address_id
      where da.subject_type_id in (1100) and v.subject_type_id=1470 and da.id not in (
          select member_subject_id from group_subject where is_voided=false and membership_end_date is null
      ) and address_level.title !='Other' ) temp;

INSERT INTO public.group_subject
(uuid, group_subject_id, member_subject_id, group_role_id, membership_start_date, membership_end_date, organisation_id,
 audit_id, is_voided, version, created_by_id, last_modified_by_id, created_date_time, last_modified_date_time,
 member_subject_address_id, group_subject_address_id, group_subject_sync_concept_1_value,
 group_subject_sync_concept_2_value, sync_disabled, sync_disabled_date_time)
select uuid_generate_v4(), temp.group_id, temp.member_id, 825, temp.custom_timestamp,
       null, 391, create_audit(), false, 0, 9820,
       9820, temp.custom_timestamp, temp.custom_timestamp, temp.address_id, temp.address_id,
       null, null, false, null
from (select da.id member_id, v.id group_id, da.address_id,
             current_timestamp + (random() * 1000 * interval '1 millisecond') custom_timestamp
      from individual da join individual v on da.address_id = v.address_id
                         join address_level on address_level.id = da.address_id
      where da.subject_type_id in (1099) and v.subject_type_id=1470 and da.id not in (
          select member_subject_id from group_subject where is_voided=false and membership_end_date is null
      ) and address_level.title !='Other') temp;
set role goonj;
select * from group_subject where member_subject_id in
                                  (select member_subject_id from (select member_subject_id, count(member_subject_id) as count from group_subject
                                                                  where is_voided=false
                                                                  group by member_subject_id) a where count > 1) and is_voided=false
order by member_subject_id desc;
--- 244 rows

select distinct(member_subject_address_id) from group_subject where member_subject_id in
                                                                    (select member_subject_id from (select member_subject_id, count(member_subject_id) as count from group_subject
                                                                                                    where is_voided=false
                                                                                                    group by member_subject_id) a where count > 1) and is_voided=false;
-- 12 rows
-- duplicate villages created for these addresses - these are not other - fix it
select * from address_level where id in (1154103, 858491, 1093989, 452753, 832126, 496524, 1027257, 811337, 448200, 890564, 496103, 753150);

select * from individual where address_id in (1154103, 858491, 1093989, 452753, 832126, 496524, 1027257, 811337, 448200, 890564, 496103, 753150)
order by created_date_time desc;
;
select * from group_subject where created_by_id=9820 and is_voided=true; --- 10437

select count(*) from group_subject; -- 51235

select * from encounter where individual_id in (select id from individual where address_id in
                                                                                (select address_id from
                                                                                    (select address_id, count(*) as count from individual join address_level on
                                                                                        individual.address_id = address_level.id
                                                                                     where subject_type_id=1470 and address_level.is_voided=false and individual.is_voided=false group by address_id)
                                                                                 where count > 1) and is_voided=false and subject_type_id=1470 and created_by_id!=9820) order by individual_id desc;

-- 555 duplicate Villages created - they are other - no issues
;

select address_id from
    (select address_id, count(*) as count from individual join address_level on
        individual.address_id = address_level.id
     where subject_type_id=1470 and address_level.is_voided=false and individual.is_voided=false group by address_id)
where count > 1; -- 64
select * from address_level where id in (448200, 452753, 463752, 463754, 463760, 463761, 463762, 463769, 463770, 463772, 465002, 465005, 496103, 496524, 500585, 500589, 500592, 500599, 504415, 504417, 731396, 731402, 731468, 739102, 739120, 739156, 739164, 739182, 739186, 753150, 789514, 789710, 789711, 789717, 789718, 811337, 832126, 833694, 833858, 833866, 833870, 858491, 882696, 882792, 882793, 882840, 890564, 974623, 974650, 974711, 974717, 974934, 983498, 1027257, 1030984, 1090451, 1093989, 1144134, 1144138, 1144255, 1144296, 1282423, 1282428, 1282429);







