README.md
===========

포팅 실습 시나리오
-----

## STEP1. crt0 + main.c 
main() 함수로 진입하는 지 확인
- mraminit 함수에 따른 FAILURE
- ClockForInit 함수에 따른 FAILURE
- asm Led_Display() 함수 작성 

## STEP2. uartdrv.c
printf가 동작하도록 함
- "hello, world!"
- printf() 함수 작성

## STEP3. timer.c and Interrupt
주기적인 타이머 인터럽트의 발생
- tick++
- vic

## STEP4. kernel
커널의 이식
- uc/os-ii

## STEP5. debugging
디버깅




