using UnityEngine;
using System;

/// <summary>
/// Система кубиків для D&D механік
/// Підтримує: d4, d6, d8, d10, d12, d20, d100
/// </summary>
public class DiceSystem : MonoBehaviour
{
    [Header("Налаштування анімації кубиків")]
    [SerializeField] private float rollAnimationDuration = 0.5f;
    [SerializeField] private int animationSteps = 10;
    
    // Подія для відображення результату кубика
    public static event Action<int, string> OnDiceRolled;
    
    /// <summary>
    /// Кидок кубика з заданою кількістю граней
    /// </summary>
    public int RollDice(int sides)
    {
        int result = UnityEngine.Random.Range(1, sides + 1);
        OnDiceRolled?.Invoke(result, "d" + sides);
        return result;
    }
    
    /// <summary>
    /// Кидок d4
    /// </summary>
    public int RollD4()
    {
        return RollDice(4);
    }
    
    /// <summary>
    /// Кидок d6
    /// </summary>
    public int RollD6()
    {
        return RollDice(6);
    }
    
    /// <summary>
    /// Кидок d8
    /// </summary>
    public int RollD8()
    {
        return RollDice(8);
    }
    
    /// <summary>
    /// Кидок d10
    /// </summary>
    public int RollD10()
    {
        return RollDice(10);
    }
    
    /// <summary>
    /// Кидок d12
    /// </summary>
    public int RollD12()
    {
        return RollDice(12);
    }
    
    /// <summary>
    /// Кидок d20 (основний для D&D)
    /// </summary>
    public int RollD20()
    {
        return RollDice(20);
    }
    
    /// <summary>
    /// Кидок d100 (для відсотків)
    /// </summary>
    public int RollD100()
    {
        return RollDice(100);
    }
    
    /// <summary>
    /// Кидок з модифікатором (наприклад, d20 + 5)
    /// </summary>
    public int RollWithModifier(int sides, int modifier)
    {
        return RollDice(sides) + modifier;
    }
    
    /// <summary>
    /// Перевірка навичок (кидок d20 проти складності)
    /// </summary>
    public bool SkillCheck(int modifier, int difficultyClass)
    {
        int roll = RollD20();
        int total = roll + modifier;
        bool success = total >= difficultyClass;
        
        Debug.Log($