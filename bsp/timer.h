/*
 * timer.h
 *
 *  Created on: 2010. 5. 5.
 *      Author: Jongin, Cha
 */

#ifndef TIMER_H_
#define TIMER_H_

#include "typedef.h"

#define Prescaler1 		(0xff + 1)
#define Prescaler2		16

//Function Declaration
void Timer_Init(void);
void Timer_Delay(int msec);
void Timer0_INTClear(void);
void StartTimer(void);
void StopTimer(void);
unsigned int GetElapsedTime(void);

void Buzzer_Init(void); // GPIO 쩌쩌, TIMER1 짹창짯
void Buzzer_Start(void); // TIMER1 쩍
void Buzzer_Stop(void); // TIMER1 철
void Buzzer_Set(int freq, int duration); // 쨍쨍 쩔채 쩌쨀짚

#endif /* TIMER_H_ */
