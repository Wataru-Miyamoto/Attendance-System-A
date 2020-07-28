# coding: utf-8

User.create!(name: "管理者",
             email: "sample@email.com",
             affiliation: "情報通信部",
             employee_number: 100,
             uid: "admin",
             password: "password",
             password_confirmation: "password",
             admin: true)
             
User.create!(name: "社員１",
             email: "sample-1@email.com",
             affiliation: "人事部",
             employee_number: 1,
             uid: "e1",
             password: "password",
             password_confirmation: "password")
             
User.create!(name: "社員２",
             email: "sample-2@email.com",
             affiliation: "営業部",
             employee_number: 2,
             uid: "e2",
             password: "password",
             password_confirmation: "password")
             
User.create!(name: "上長１",
             email: "sample-11@email.com",
             affiliation: "人事部",
             employee_number: 11,
             uid: "s1",
             password: "password",
             password_confirmation: "password",
             superior: true)

User.create!(name: "上長２",
             email: "sample-12@email.com",
             affiliation: "営業部",
             employee_number: 12,
             uid: "s2",
             password: "password",
             password_confirmation: "password",
             superior: true)