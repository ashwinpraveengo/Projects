import asyncio
import io
from tkinter import Canvas
import discord
from discord.ext import commands
import requests
from bs4 import BeautifulSoup
from datetime import datetime, timedelta
import random

intents = discord.Intents.default()
intents.messages = True 
intents.message_content = True

def scrape_questions_and_answers(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')
    questions = soup.find_all('div', class_='wp_quiz_question')
    answers = soup.find_all('div', class_='wp_basic_quiz_answer')
    
    question_texts = [question.text.strip() for question in questions]
    correct_answers = [answer.find('b').text.strip() for answer in answers]
    
    return question_texts, correct_answers

def scrape_current_affairs(start_date, end_date):
    current_date = start_date
    questions_answers = {}
    while current_date <= end_date:
        url = f"https://www.gktoday.in/daily-current-affairs-quiz-{current_date.strftime('%B').lower()}-{current_date.strftime('%-d')}-{current_date.year}/"
        questions, answers = scrape_questions_and_answers(url)
        questions_answers[current_date.strftime('%B %d, %Y')] = list(zip(questions, answers))
        current_date += timedelta(days=1)  
    return questions_answers

prefix = "!"
intents.members = True
intents.typing = True
intents.presences = True
bot = commands.Bot(command_prefix=prefix, intents=intents)

@bot.event
async def on_ready():
    print(f'{bot.user} has connected to Discord!')

@bot.command(name='current_affairs', help='Scrapes and sends current affairs questions and answers')
async def current_affairs(ctx, date: str = None):
    if date is None:
        date = datetime.now().strftime('%Y-%m-%d')
    try:
        target_date = datetime.strptime(date, '%Y-%m-%d')
    except ValueError:
        await ctx.send("Invalid date format. Please use YYYY-MM-DD.")
        return
    
    questions_answers = scrape_current_affairs(target_date, target_date)
    
    for date, qa_pairs in questions_answers.items():
        await ctx.send(f"Date: {date}")
        for i, (question, answer) in enumerate(qa_pairs, start=1):
            await ctx.send(f"Question {i}: {question}")
            await ctx.send(f"Correct Answer: {answer}")

@bot.command(name='pdf', help='Generates a PDF file of current affairs questions and answers')
async def generate_pdf(ctx, date: str = None):
    if date is None:
        date = datetime.now().strftime('%Y-%m-%d')
    try:
        target_date = datetime.strptime(date, '%Y-%m-%d')
    except ValueError:
        await ctx.send("Invalid date format. Please use YYYY-MM-DD.")
        return
    
    questions_answers = scrape_current_affairs(target_date, target_date)
    
    pdf_buffer = io.BytesIO()
    c = Canvas.Canvas(pdf_buffer)
    y = 750
    for date, qa_pairs in questions_answers.items():
        c.drawString(100, y, f"Date: {date}")
        y -= 20
        for i, (question, answer) in enumerate(qa_pairs, start=1):
            c.drawString(100, y, f"Question {i}: {question}")
            y -= 15
            c.drawString(100, y, f"Correct Answer: {answer}")
            y -= 15
    c.save()
    
    pdf_buffer.seek(0)
    await ctx.send(file=discord.File(pdf_buffer, filename=f"Current_Affairs_{date}.pdf"))

@bot.command(name='test', help='A test command to check if the bot is responsive')
async def test(ctx):
    await ctx.send('Bot is online and responsive!')

@bot.command(name='Help', help='Displays all available commands')
async def help(ctx):
    command_list = [
        "!current_affairs [date]",
        "!pdf [date]",
        "!test",
        "!help",
        "!quiz [points]"
    ]
    await ctx.send("Available commands:\n" + "\n".join(command_list))

@bot.command(name='quiz', help='Plays a quiz game')
async def quiz(ctx, points: int = 5):
    if points <= 0:
        await ctx.send("Please provide a positive number of points.")
        return
    
    date = datetime.now().strftime('%Y-%m-%d')
    questions_answers = scrape_current_affairs(datetime.now(), datetime.now())
    
    all_questions = []
    all_answers = []
    for qa_pairs in questions_answers.values():
        for question, answer in qa_pairs:
            all_questions.append(question)
            all_answers.append(answer)
    
    selected_questions_indices = random.sample(range(len(all_questions)), min(points, len(all_questions)))
    selected_questions = [all_questions[i] for i in selected_questions_indices]
    correct_answers = [all_answers[i] for i in selected_questions_indices]
    
    print("Selected Questions:")
    print(selected_questions)
    print("Correct Answers:")
    print(correct_answers)
    
    score = 0
    await ctx.send(f"Welcome to the quiz! You have {points} questions to answer.")
    
    for i, (question, answer) in enumerate(zip(selected_questions, correct_answers), start=1):
        await ctx.send(f"Question {i}: {question}")
        
        try:
            response = await bot.wait_for('message', check=lambda m: m.author == ctx.author, timeout=30.0)
            if response.content.strip().lower() == answer.lower():
                await ctx.send("Correct!")
                score += 1
            else:
                await ctx.send(f"Wrong! Correct answer is: {answer}")
        except asyncio.TimeoutError:
            await ctx.send("Time's up! Moving to the next question.")
    
    await ctx.send(f"Quiz completed! Your score: {score}/{len(selected_questions)}")

bot.run('MTIwMzM2NzEzNzMxODgwNTU3NA.GlCMvN.22TdofDNQZrTn47IQjr-MvhDq6acWPRha0cdXE')
