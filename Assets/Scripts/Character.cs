using UnityEngine;
using System;

/// <summary>
/// Клас персонажа для D&D гри
/// Зберігає характеристики, інвентар, рівень тощо
/// </summary>
[Serializable]
public class Character
{
    [Header("Основна інформація")]
    public string characterName = "Герой";
    public string characterClass = "Слідопит";
    public int level = 1;
    public int experience = 0;
    public int gold = 50;
    
    [Header("Характеристики")]
    public int Strength = 10;     // Сила
    public int Dexterity = 10;    // Спритність
    public int Constitution = 10; // Конституція
    public int Intelligence = 10; // Інтелект
    public int Wisdom = 10;       // Мудрість
    public int Charisma = 10;     // Харизма
    
    [Header("Бойові характеристики")]
    public int currentHealth;
    public int maxHealth = 10;
    public int armorClass = 10;
    public int initiative = 0;
    
    [Header("Інвентар")]
    public string[] inventory = new string[10];
    
    /// <summary>
    /// Конструктор
    /// </summary>
    public Character()
    {
        // Встановлюємо початкові значення
        currentHealth = maxHealth;
        CalculateDerivedStats();
    }
    
    /// <summary>
    /// Розрахунок похідних характеристик
    /// </summary>
    public void CalculateDerivedStats()
    {
        // Максимальне здоров'я залежно від Конституції
        maxHealth = 10 + GetModifier(Constitution) * level;
        currentHealth = Mathf.Min(currentHealth, maxHealth);
        
        // Клас броні (AC)
        armorClass = 10 + GetModifier(Dexterity);
        
        // Ініціатива
        initiative = GetModifier(Dexterity);
    }
    
    /// <summary>
    /// Отримати модифікатор характеристики (D&D правило)
    /// </summary>
    public int GetModifier(int statValue)
    {
        return (statValue - 10) / 2;
    }
    
    /// <summary>
    /// Додати досвід
    /// </summary>
    public void AddExperience(int xp)
    {
        experience += xp;
        
        // Перевірка на підвищення рівня
        int requiredXP = level * 100;
        while (experience >= requiredXP)
        {
            experience -= requiredXP;
            level++;
            requiredXP = level * 100;
            
            // Покращуємо характеристики при підвищенні рівня
            maxHealth += GetModifier(Constitution) + 1;
            currentHealth = maxHealth;
        }
        
        CalculateDerivedStats();
    }
    
    /// <summary>
    /// Додати золото
    /// </summary>
    public void AddGold(int amount)
    {
        gold += amount;
    }
    
    /// <summary>
    /// Витратити золото
    /// </summary>
    public bool SpendGold(int amount)
    {
        if (gold >= amount)
        {
            gold -= amount;
            return true;
        }
        return false;
    }
    
    /// <summary>
    /// Додати предмет до інвентаря
    /// </summary>
    public bool AddToInventory(string item)
    {
        for (int i = 0; i < inventory.Length; i++)
        {
            if (inventory[i] == null)
            {
                inventory[i] = item;
                return true;
            }
        }
        return false; // Інвентар заповнений
    }
    
    /// <summary>
    /// Видалити предмет з інвентаря
    /// </summary>
    public bool RemoveFromInventory(string item)
    {
        for (int i = 0; i < inventory.Length; i++)
        {
            if (inventory[i] == item)
            {
                inventory[i] = null;
                return true;
            }
        }
        return false; // Предмет не знайдений
    }
    
    /// <summary>
    /// Отримати кількість предметів у інвентарі
    /// </summary>
    public int GetInventoryCount()
    {
        int count = 0;
        foreach (var item in inventory)
        {
            if (item != null) count++;
        }
        return count;
    }
    
    /// <summary>
    /// Отримати модифікатор Сили
    /// </summary>
    public int GetStrengthModifier() => GetModifier(Strength);
    
    /// <summary>
    /// Отримати модифікатор Спритності
    /// </summary>
    public int GetDexterityModifier() => GetModifier(Dexterity);
    
    /// <summary>
    /// Отримати модифікатор Конституції
    /// </summary>
    public int GetConstitutionModifier() => GetModifier(Constitution);
    
    /// <summary>
    /// Отримати модифікатор Інтелекту
    /// </summary>
    public int GetIntelligenceModifier() => GetModifier(Intelligence);
    
    /// <summary>
    /// Отримати модифікатор Мудрості
    /// </summary>
    public int GetWisdomModifier() => GetModifier(Wisdom);
    
    /// <summary>
    /// Отримати модифікатор Харизми
    /// </summary>
    public int GetCharismaModifier() => GetModifier(Charisma);
    
    /// <summary>
    /// Отримати інформацію про персонажа у вигляді рядка
    /// </summary>
    public override string ToString()
    {
        return $"{characterName} ({characterClass}, рівень {level})\n" +
               $