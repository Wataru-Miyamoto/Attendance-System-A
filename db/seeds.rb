# coding: utf-8

User.create!(name: "管理者",
             email: "sample@email.com",
             password: "password",
             password_confirmation: "password",
             admin: true)
             
User.create!(name: "社員１",
             email: "sample-1@email.com",
             password: "password",
             password_confirmation: "password")
             
User.create!(name: "社員２",
             email: "sample-2@email.com",
             password: "password",
             password_confirmation: "password")
             
User.create!(name: "上長１",
             email: "sample-11@email.com",
             password: "password",
             password_confirmation: "password",
             superior: true)

User.create!(name: "上長２",
             email: "sample-12@email.com",
             password: "password",
             password_confirmation: "password",
             superior: true)