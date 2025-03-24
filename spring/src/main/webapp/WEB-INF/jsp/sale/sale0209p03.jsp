<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 생산발주산출수량 > 발주수량등록 > null
-- 작성자 : 김경빈
-- 최초 작성일 : 2023-03-17 11:03:59
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	let auiGridExpect; // 예상수량산출 데이터 원본
	let auiGridWeight; // 판매추이증가 모델별 가중치
	let auiGridCalc; // 산출수량
	let calcQtyMonList; // 산출수량 월 리스트
	let expectQtyList = ${expectQtyList}; // 예상수량 그리드 데이터
	let weightList = ${weightList}; // 가중치 그리드 데이터
	const isEditableWorkerOrder = ${isEditableWorkerOrder}; // 실무자 발주수량 수정가능 여부
	const isEditableMngOrder = ${isEditableMngOrder}; 		// 관리자 최종 발주수량 수정가능 여부

	const expectYearMon = ${cal_mon}; // 산출해야할 년월

	// 비율 editRenderer 설정
	const editRendererForRate = {
		onlyNumeric : true, // 숫자만
		allowNegative : true, // 마이너스 허용
		maxlength: 6,
	};

	$(document).ready(function() {
		createAUIGridExpect();
		createAUIGridWeight();
		createAUIGridCalc();
	});

	// 닫기
	function fnClose() {
		window.close();
	}

	// 예상수량산출 그리드 생성
	function createAUIGridExpect() {
		const gridPros = {
			headerHeight : 30,
			showRowNumColumn: false, // 행 줄번호(로우 넘버링) 칼럼의 출력 여부를 지정
			enableCellMerge: true, // 셀병합 사용여부
			rowStyleFunction : function(rowIndex, item) {
				// 실제수량의 년도가 아직 지나지 않았다면 색상을 다르게 표시
				if (item.title == "실제수량" && $M.toDate(item.yyyy + "1231") > new Date()) {
					return "aui-as-tot-row-style";
				}
				return "aui-center";
			},
		};

		const columnLayout = [
			{
				headerText : "예상수량 산출</br>적용기간(과거)",
				dataField : "title",
				style : "aui-center",
				cellColMerge: true, // 셀 가로병합
			},
			{
				headerText : "년도",
				dataField : "yyyy",
				width : "50",
				style : "aui-center",
				cellColMerge : true, // 셀 가로병합
			},
			{
				headerText : "계약수량",
				children: [
					{
						headerText: "1톤 미만",
						dataField: "a_0101_cnt",
						width : "60",
						dataType : "numeric",
						formatString: "#,##0",
						editRenderer : editRendererForRate,
						labelFunction : customLabelFunction2,
						styleFunction : customStyleFunction,
					},
					{
						headerText: "1.5톤",
						dataField: "a_0102_cnt",
						width : "60",
						dataType : "numeric",
						formatString: "#,##0",
						editRenderer : editRendererForRate,
						labelFunction : customLabelFunction2,
						styleFunction : customStyleFunction,
					},
					{
						headerText: "2톤",
						dataField: "a_0103_cnt",
						width : "60",
						dataType : "numeric",
						formatString: "#,##0",
						editRenderer : editRendererForRate,
						labelFunction : customLabelFunction2,
						styleFunction : customStyleFunction,
					},
					{
						headerText: "3톤",
						dataField: "a_0104_cnt",
						width : "60",
						dataType : "numeric",
						formatString: "#,##0",
						editRenderer : editRendererForRate,
						labelFunction : customLabelFunction2,
						styleFunction : customStyleFunction,
					},
					{
						headerText: "5톤",
						dataField: "a_0105_cnt",
						width : "60",
						dataType : "numeric",
						formatString: "#,##0",
						editRenderer : editRendererForRate,
						labelFunction : customLabelFunction2,
						styleFunction : customStyleFunction,
					},
					{
						headerText: "8톤",
						dataField: "a_0106_cnt",
						width : "60",
						dataType : "numeric",
						formatString: "#,##0",
						editRenderer : editRendererForRate,
						labelFunction : customLabelFunction2,
						styleFunction : customStyleFunction,
					},
					{
						headerText: "Total",
						dataField: "a_total_cnt",
						width : "60",
						style : "aui-center",
						formatString : "#,##0",
					},
					{
						headerText: "전년대비",
						dataField: "compare_rate",
						width : "60",
						style : "aui-center",
						labelFunction : customLabelFunction1,
					}
				]
			}
		];

		auiGridExpect = AUIGrid.create("#auiGridExpect", columnLayout, gridPros);

		let newExpectQtyList = JSON.parse(JSON.stringify(expectQtyList));

		// 예상수량 값 산출
		const keyArr = Object.keys(expectQtyList[0]).filter(key => key.startsWith("a_"));
		keyArr.forEach(key => {
			const growRate = expectQtyList[0][key] / 100; // 성장조정 비율
			newExpectQtyList[1][key] = Math.round(expectQtyList[1][key] * growRate); // 해당 톤 예상수량 * 성장 조정 비율
		});

		// 예상수량 Total 값 산출
		let totalVal = 0;
		keyArr.forEach(key => {
			totalVal += newExpectQtyList[1][key];
			newExpectQtyList[1]["a_total_cnt"] = totalVal;
		});

		AUIGrid.setGridData(auiGridExpect, newExpectQtyList);
		$("#auiGridExpect").resize();

		AUIGrid.bind(auiGridExpect, "cellClick", function(event) {
			// 첫번째 행 및 1톤 미만 ~ 8톤까지만 수정 가능
			if (event.rowIndex !== 0 || !event.dataField.startsWith("a_") || event.dataField.includes("total")) {
				return false;
			}
			AUIGrid.setProp(auiGridExpect, "editable", true);
		});

		AUIGrid.bind(auiGridExpect, "cellEditBegin", function(event) {
			// 첫번째 행 및 1톤 미만 ~ 8톤까지만 수정 가능
			if (event.rowIndex !== 0 || !event.dataField.startsWith("a_") || event.dataField.includes("total")) {
				return false;
			}
		});

		AUIGrid.bind(auiGridExpect, "cellEditEnd", function(event) {
			// '성장 % 조정' 비율 수정 시, 예상수량 자동계산
			const realRate = (event.value / 100); // '성장 % 조정' 값
			let expectQty = expectQtyList[1][event.dataField]; // 해당 톤 예상수량
			expectQty *= realRate;
			AUIGrid.setCellValue(auiGridExpect, 1, event.dataField, Math.round(expectQty));

			// 수정가능 false
			AUIGrid.setProp(auiGridExpect, "editable", false);

			// 예상수량 Total 값 자동계산 처리
			let gridData = AUIGrid.getGridData(auiGridExpect);
			let totalVal = 0;
			Object.keys(gridData[1])
					.filter(k => k.includes("a_") && !k.includes("total"))
					.forEach(key => totalVal += gridData[1][key]);
			AUIGrid.setCellValue(auiGridExpect, 1, "a_total_cnt", totalVal);
		});
	}

	// 판매추이증가 모델별 가중치 그리드 생성
	function createAUIGridWeight() {
		const gridPros = {
			showStateColumn: true,
			enableSorting : false,
			showRowNumColumn: false,
			headerHeight: 60,
			editable: true,
			enableCellMerge: true, // 셀 병합 실행
			cellMergePolicy: "withNull", // null 도 하나의 값으로 간주하여 다수의 null 을 병합된 하나의 공백으로 출력
		};

		const columnLayout = [
			{
				headerText : "규격",
				dataField : "machine_sub_type_name",
				width : "70",
				style : "aui-center",
				editable: false,
				cellMerge: true, // 셀 세로 병합 실행
			},
			{
				headerText : "모델명",
				dataField : "machine_name",
				style : "aui-center",
				editable: false,
			},
			{
				headerText : "가중치</br>(%)",
				dataField : "weight_rate",
				width : "80",
				style : "aui-editable",
				dataType : "numeric",
				formatString: "#,###.##",
				editRenderer: editRendererForRate,
			},
			{
				headerText : "과거3년간</br>판매비율(%)",
				dataField : "year3_sale_rate",
				width : "80",
				style : "aui-editable",
				editable: true,
				dataType : "numeric",
				formatString: "#,###.##",
				editRenderer: editRendererForRate,
			},
			{
				headerText : "과거3년간</br>판매비율</br>합계",
				dataField : "year3_sale_rate_total",
				width : "80",
				style : "aui-center",
				editable: false,
				cellMerge: true, // 셀 세로 병합 실행
				mergeRef: "machine_sub_type_name", // '규격' 셀의 값을 기준으로 머지 실행
				mergePolicy: "restrict", // mergeRef를 위한 필수값
				dataType : "numeric",
				formatString : "#,##0",
				labelFunction :customLabelFunction1,
			},
			{
				dataField : "weight_machine_plant_seq",
				visible : false,
			}
		];

		auiGridWeight = AUIGrid.create("#auiGridWeight", columnLayout, gridPros);

		// 그리드 생성 후, [과거3년간 판매비율 합계] 계산
		for (let i in weightList) {
			let rate = 0;
			let idxArr = []; // 동일규격 인덱스 리스트
			const data = weightList[i];
			const subtypeCd = data.machine_sub_type_cd;

			for (let j in weightList) {
				if (subtypeCd == weightList[j].machine_sub_type_cd) {
					idxArr.push(j);
					rate += weightList[j].year3_sale_rate;
				}
			}
			// 동일 규격의 행에 세팅
			idxArr.forEach(idx => {
				weightList[idx].year3_sale_rate_total = rate;
			});
		}

		AUIGrid.setGridData(auiGridWeight, weightList);
		$("#auiGridWeight").resize();

		AUIGrid.bind(auiGridWeight, "cellEditEnd", function(event) {

			// 과거3년간 판매비율 수정 시, 합계 비율 자동계산
			if (event.dataField == 'year3_sale_rate') {
				let value = event.value;
				let rowIdxArr = [event.rowIndex]; // 동일 규격 행 인덱스

				for (let i=0; i<AUIGrid.getRowCount(auiGridWeight); i++) {
					// 해당 행은 제외
					if (i == event.rowIndex) {
						continue;
					}
					// 동일 규격 행 인덱스 배열에 추가
					if (AUIGrid.getCellValue(auiGridWeight, i, "machine_sub_type_cd") == event.item.machine_sub_type_cd) {
						value += AUIGrid.getCellValue(auiGridWeight, i, "year3_sale_rate");
						rowIdxArr.push(i);
					}
				}
				// 동일 규격의 행에 세팅
				rowIdxArr.forEach(idx => {
					AUIGrid.setCellValue(auiGridWeight, idx, "year3_sale_rate_total", value);
				});
			}
		});
	}

	// 산출수량 그리드 생성
	function createAUIGridCalc() {
		// 산출월
		let expectMon = String(expectYearMon).substring(4, 6);
		expectMon = expectMon.startsWith("0") ? expectMon.replace("0", "") : expectMon;

		const gridPros = {
			showStateColumn: true,
			enableSorting : false,
			showRowNumColumn: false,
			headerHeight: 50,
			editable: true,
			footerPosition : "bottom",
			showFooter : true,
		};

		const columnLayout = [
			{
				headerText : "모델",
				dataField : "machine_name",
				style : "aui-center",
				editable: false,
			},
			{
				headerText : "Total",
				dataField : "sub_total_qty",
				width : "60",
				style : "aui-center",
				dataType : "numeric",
				formatString : "#,##0",
				editable : false,
				headerTooltip: {
					show: true,
					tooltipHtml: "전월YCE재고 + YK재고 + 수주잔고 ~" + expectMon + "월 산출량",
				},
			},
			{
				headerText : "전월YCE재고<br/>${shortDt}",
				headerStyle : "aui-as-center-row-style",
				dataField : "a_yce_stock",
				width : "9%",
				minWidth : "80",
				style : "aui-center",
				dataType : "numeric",
				formatString : "#,##0",
				editable : false,
			},
			{
				headerText : "YK재고 ${shortDt}<br/>(선적포함)",
				headerStyle : "aui-as-center-row-style",
				dataField : "a_yk_stock",
				width : "9%",
				minWidth : "80",
				style : "aui-center",
				dataType : "numeric",
				formatString : "#,##0",
				editable : false,
			},
			{
				dataField : "calc_machine_plant_seq",
				visible : false,
			}
		];

		auiGridCalc = AUIGrid.create("#auiGridCalc", columnLayout, gridPros);

		// 해당월 포함 이후 4개월 컬럼 생성
		// (하단 footer 로직 - 운영쪽에 반영되어 있음)
		var monColumnArr = [];
		for (let i=0; i<4; i++) {
			let sYearMon = $M.dateFormat($M.addMonths($M.toDate(String(${oriYearMon})), i), "yyyyMM");
			const mon = Number(sYearMon.substring(4, 6));

			const dataField = "a_" + sYearMon + "_qty";
			const columnObj = {
				headerText : i == 3 ? mon + "월 산출량" : mon + "월",
				headerStyle : i == 3 ? "aui-as-tot-row-style" : "aui-center",
				dataField : dataField,
				style : "aui-center",
				width : "8%",
				dataType : "numeric",
				formatString: "#,##0",
				editable: false,
			};
			monColumnArr.push(columnObj); // footer 생성을 위한 obj 백업
			AUIGrid.addColumn(auiGridCalc, columnObj, 'last');
		}

		// 나머지 컬럼 생성
		const addColumnList = [
			{
				headerText : "해당월기준</br>수주잔고",
				headerStyle : "aui-as-tot-row-style",
				dataField : "jango",
				style : "aui-center",
				width : "8%",
				minWidth : "70",
				dataType : "numeric",
				formatString: "#,##0",
				editable: false,
			},
			{
				headerText : expectMon + "월</br>총 산출수량",
				headerStyle : "aui-as-tot-row-style",
				dataField : "a_tot_calc",
				style : "aui-center",
				width : "8%",
				minWidth : "70",
				dataType : "numeric",
				formatString: "#,##0",
				editable: false,
				headerTooltip: {
					show: true,
					tooltipHtml: expectMon + "월 산출량 + 해당월기준 수주잔고",
				},
			},
			{
				headerText : "실무자</br>발주수량",
				headerStyle : "aui-background-darkgray",
				dataField : "worker_order_cnt",
				width : "9%",
				dataType : "numeric",
				formatString: "#,###",
				editable : true,
				labelFunction : customLabelFunction3,
				styleFunction : function (rowIndex, columnIndex, value, headerText, item, dataField) {
					if (isEditableWorkerOrder === true) {
						return "aui-editable";
					}
					return "aui-status-complete";
				},
				editRenderer : {
					onlyNumeric : true,
					allowNegative : true,
					maxlength : 10,
				},
			},
			{
				headerText : "관리자 최종</br>발주수량",
				headerStyle : "aui-background-darkgray",
				dataField : "mng_order_cnt",
				width : "9%",
				dataType : "numeric",
				formatString: "#,###",
				editable : true,
				labelFunction : customLabelFunction3,
				styleFunction : function (rowIndex, columnIndex, value, headerText, item, dataField) {
					if (isEditableMngOrder === true) {
						return "aui-editable";
					}
					return "aui-status-complete";
				},
				editRenderer : {
					onlyNumeric : true,
					allowNegative : true,
					maxlength : 10,
				},
			}
		];
		AUIGrid.addColumn(auiGridCalc, addColumnList, 'last');

		// 푸터레이아웃
		var footerColumnLayout = [
			{
				labelText : "합계",
				positionField : "machine_name",
				style : "aui-center aui-footer"
			},
			{
				dataField : "sub_total_qty",
				positionField : "sub_total_qty",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer",
			},
			{
				dataField : "a_yce_stock",
				positionField : "a_yce_stock",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer",
			},
			{
				dataField : "a_yk_stock",
				positionField : "a_yk_stock",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer",
			},
			{
				dataField : "jango",
				positionField : "jango",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer",
			},
			{
				dataField : "a_tot_calc",
				positionField : "a_tot_calc",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer",
			},
			{
				dataField : "worker_order_cnt",
				positionField : "worker_order_cnt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer",
			},
			{
				dataField : "mng_order_cnt",
				positionField : "mng_order_cnt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer",
			},
		];
		// 동적 컬럼 푸터 생성
		for (let i = 0; i < monColumnArr.length; i++) {
			footerColumnLayout.push({
				dataField : monColumnArr[i].dataField,
				positionField : monColumnArr[i].dataField,
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer",
			})
		}
		// 푸터 객체 세팅
		AUIGrid.setFooter(auiGridCalc, footerColumnLayout);

		AUIGrid.setGridData(auiGridCalc, ${calcQtyList});
		$("#auiGridCalc").resize();

		// 편집가능 변수에 따른 편집 가능 세팅
		AUIGrid.bind(auiGridCalc, "cellClick", function(event) {
			// 발주수량 셀만 편집 가능
			if (event.dataField != "worker_order_cnt" && event.dataField != "mng_order_cnt") {
				return false;
			}
			// 클릭한 셀 및 변수에 따른 세팅
			if ( !(isEditableWorkerOrder && event.dataField == "worker_order_cnt")
					&& !(isEditableMngOrder && event.dataField == "mng_order_cnt") ) {
				return false;
			}
		});

		AUIGrid.bind(auiGridCalc, "cellEditBegin", function(event) {
			if (event.dataField != "worker_order_cnt" && event.dataField != "mng_order_cnt") {
				return false;
			}
			if ( !(isEditableWorkerOrder && event.dataField == "worker_order_cnt")
					&& !(isEditableMngOrder && event.dataField == "mng_order_cnt")
			) {
				return false;
			}
		});

	}

	// 실제판매비율 팝업 호출
	function goRealSaleRate() {
		const param = {
			s_maker_cd : ${inputParam.s_maker_cd},
			s_year : "${inputParam.s_year_mon}".substring(0, 4),
		};
		$M.goNextPage('/sale/sale0209p02', $M.toGetParam(param), {popupStatus : ""});
	}

	// 예상수량산출 적용기간 변경
	function fnChangePeriodYear(value) {
		if (value) {
			const param = {
				s_period_year : value,
				s_maker_cd : ${inputParam.s_maker_cd},
				s_year : "${inputParam.s_year_mon}".substring(0, 4),
			};
			$M.goNextPageAjax("/sale/sale0209p01/calcExpectQty", $M.toGetParam(param), {method : "GET", loader: true},
				function(result) {
					if (result.success && result.list) {
						AUIGrid.destroy("#auiGridExpect");
						auiGridExpect = null;
						expectQtyList = result.list;
						createAUIGridExpect();
					}
				}
			);
		}
	}

	// 상단비율저장
	function goModify() {

		// 과거3년간 판매비율 합계 validation
		const weightGridData = AUIGrid.getGridData(auiGridWeight);
		for (let i in weightGridData) {
			let data = weightGridData[i];
			if (data.year3_sale_rate_total && data.year3_sale_rate_total != 100) {
				alert("'과거3년간 판매비율 합계'는 100%가 되어야 합니다.");
                $("#auiGridWeight").focus();
				return false;
			}
		}

		// 예상수량산출 그리드에서 성장 % 조정 비율값 추출
		const expectGridData = AUIGrid.getGridData(auiGridExpect)[0];
		const growRate = {
			grow_1ton_rate : expectGridData.a_0101_cnt,
			grow_1_5ton_rate : expectGridData.a_0102_cnt,
			grow_2ton_rate : expectGridData.a_0103_cnt,
			grow_3ton_rate : expectGridData.a_0104_cnt,
			grow_5ton_rate : expectGridData.a_0105_cnt,
			grow_10ton_rate : expectGridData.a_0106_cnt,
		}
		const growRateForm = $M.toForm(growRate);

		// 가중치 그리드 저장
		const frm = $M.toValueForm(document.main_form);
		const gridFrm = fnChangeGridDataToForm(auiGridWeight);
		$M.copyForm(gridFrm, growRateForm);
		$M.copyForm(gridFrm, frm);

		$M.goNextPageAjaxSave("/sale/sale0209p01/modify", gridFrm, {method : 'POST'},
			function(result) {
		    	if(result.success) {
					alert(result.result_msg);
					location.reload();
					opener.goSearch();
				}
			}
		);
	}

	// 발주수량저장 및 결재요청
	function goSave(type) {
		let msg = "저장하시겠습니까?";
		let saveMode = "save";

		// 결재요청 시
		if (type == "request") {
			msg = "결재 요청 하시겠습니까?\n요청 후 수정이 불가능 합니다.";
			saveMode = "appr";
		}

		// 산출수량 변경내역 체크
		const editedGridData = AUIGrid.getEditedRowItems(auiGridCalc);
		if (editedGridData.length === 0 && !type) {
			alert("변경내역이 없습니다.");
			return false;
		}

		$M.setValue("save_mode", saveMode);

		const frm = $M.toValueForm(document.main_form);
		const gridFrm = fnChangeGridDataToForm(auiGridCalc); // 산출수량 그리드
		$M.copyForm(gridFrm, frm);

		$M.goNextPageAjaxMsg(msg, "/sale/sale0209p01/save", gridFrm, {method : 'POST'},
			function(result) {
		    	if(result.success) {
					alert("처리가 완료되었습니다.");
					if (opener != null) {
						opener.goSearch();
					}
					const param = {
						s_year_mon : ${inputParam.s_year_mon},
						s_maker_cd : ${inputParam.s_maker_cd},
						mch_order_cal_seq : result.mch_order_cal_seq,
					};
					$M.goNextPage('/sale/sale0209p01', $M.toGetParam(param), {popupStatus : ""});
					window.close();
				}
			}
		);
	}

	// 결재요청
	function goRequestApproval() {
		// 실무자 발주수량 validation
        if (!validationCalcGrid()) {
			return false;
		}
		goSave("request");
	}

	/**
	 * 발주수량 빈값 체크
	 * @returns {boolean}
	 */
	function validationCalcGrid() {
		// 실무자 발주수량, 관리자 최종 발주수량 빈값 체크
        let gridData = AUIGrid.getGridData(auiGridCalc);
        for (let i in gridData) {
            let data = gridData[i];
            if (isEditableWorkerOrder === true && !data.worker_order_cnt) {
                alert("'실무자 발주수량'은 필수값입니다");
                return false;
            } else if (isEditableMngOrder === true && !data.mng_order_cnt) {
                alert("'관리자 최종 발주수량'은 필수값입니다");
                return false;
            }
        }
		return true;
	}

	// % 붙여주는 Label Function
	function customLabelFunction1(rowIndex, columnIndex, value, headerText, item) {
		return value ? value + "%" : "";
	}

	// 첫번째 행만 퍼센트로 산출 및 '%' 추가
	function customLabelFunction2(rowIndex, columnIndex, value, headerText, item) {
		// 첫번째 행
		if (rowIndex === 0) {
			return value ? value + "%" : "";
		}
		return value;
	}

	// 값이 없으면 빈칸으로 변경
	function customLabelFunction3(rowIndex, columnIndex, value, headerText, item) {
		return value ? value : "";
	}

	// 첫번째 행은 수정가능한 스타일로 변경 및 실제수량의 년도가 아직 지나지 않았다면 색상을 다르게 표시
	function customStyleFunction(rowIndex, columnIndex, value, headerText, item, dataField) {
		if (rowIndex == 0) {
			return "aui-editable";
		} else if (item.title == "실제수량" && $M.toDate(item.yyyy + "1231") > new Date()) {
			return "aui-as-tot-row-style";
		}
		return "aui-center";
	}

	</script>
</head>
<body>
<form id="main_form" name="main_form">
    <input type="hidden" id="appr_job_seq" name="appr_job_seq" value="${appr_job_seq}">
	<input type="hidden" id="cal_year" name="cal_year" value="${cal_year}">
	<input type="hidden" id="cal_mon" name="cal_mon" value="${cal_mon}">
	<input type="hidden" id="mch_order_cal_seq" name="mch_order_cal_seq" value="${mch_order_cal_seq}">
	<!-- 팝업 -->
    <div class="popup-wrap width-100per" style="min-width: 1280px">
		<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
		<!-- 컨텐츠 영역 -->
        <div class="content-wrap">
			<!-- 서브타이틀영역 -->
			<div class="title-wrap half-print">
				<h4 class="primary">발주수량등록</h4>
				<!-- 결재영역 -->
				<div><jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include></div>
			</div>
			<!-- 상단 폼테이블 -->
			<div class="row mt7">
				<!-- 좌측 폼테이블 -->
				<div class="col-6">
					<div class="title-wrap mt5" style="justify-content: start !important;">
						<h4>예상수량산출 적용기간</h4>
						<select class="form-control ml5" id="s_period_year" name="s_period_year" onchange="fnChangePeriodYear(this.value)" style="width: 70px;">
							<c:forEach var="i" begin="3" end="10" step="1">
								<option value="${i}" <c:if test="${i == 3}">selected</c:if>>${i}년</option>
							</c:forEach>
						</select>
					</div>
					<div id="auiGridExpect" style="margin-top: 5px; height: 295px;">
					</div>
				</div>
				<!-- 중앙 폼테이블 - 판매수량별 비율 -->
				<div class="col-2">
					<div class="mb5">
						<div class="title-wrap mt5">
							<h4>
								판매수량별 비율
								<span class="text-muted" style="font-size: 10px;">ㅣ이상재고 비율(Forecast 기준)</span>
							</h4>
						</div>
						<table class="table-border doc-table mt5" id="saleQtyRateTable">
							<colgroup>
								<col width="50%">
								<col width="50%">
							</colgroup>
							<thead>
								<tr>
									<th class="title-bg">1년 판매수량</th>
									<th class="title-bg">비율</th>
								</tr>
							</thead>
							<tbody>
								<tr>
									<th>100대 이상</th>
									<td>
										<div class="form-row inline-pd" style="padding-right: 5px; padding-left: 5px;">
											<div class="col-10">
												<input type="text" class="form-control text-right" id="sale_100over_rate" name="sale_100over_rate" format="num" value="${saleRateList.sale_100over_rate}" maxlength="6">
											</div>
											<div class="col-2">%</div>
										</div>
									</td>
								</tr>
								<tr>
									<th>50~100</th>
									<td>
										<div class="form-row inline-pd" style="padding-right: 5px; padding-left: 5px;">
											<div class="col-10">
												<input type="text" class="form-control text-right" id="sale_50_100_rate" name="sale_50_100_rate" format="num" value="${saleRateList.sale_50_100_rate}" maxlength="6">
											</div>
											<div class="col-2">%</div>
										</div>
									</td>
								</tr>
								<tr>
									<th>30~50</th>
									<td>
										<div class="form-row inline-pd" style="padding-right: 5px; padding-left: 5px;">
											<div class="col-10">
												<input type="text" class="form-control text-right" id="sale_30_50_rate" name="sale_30_50_rate" format="num" value="${saleRateList.sale_30_50_rate}" maxlength="6">
											</div>
											<div class="col-2">%</div>
										</div>
									</td>
								</tr>
								<tr>
									<th>20~30</th>
									<td>
										<div class="form-row inline-pd" style="padding-right: 5px; padding-left: 5px;">
											<div class="col-10">
												<input type="text" class="form-control text-right" id="sale_20_30_rate" name="sale_20_30_rate" format="num" value="${saleRateList.sale_20_30_rate}" maxlength="6">
											</div>
											<div class="col-2">%</div>
										</div>
									</td>
								</tr>
								<tr>
									<th>~20</th>
									<td>
										<div class="form-row inline-pd" style="padding-right: 5px; padding-left: 5px;">
											<div class="col-10">
												<input type="text" class="form-control text-right" id="sale_20_rate" name="sale_20_rate" format="num" value="${saleRateList.sale_20_rate}" maxlength="6">
											</div>
											<div class="col-2">%</div>
										</div>
									</td>
								</tr>
								<tr>
									<th>모델아웃</th>
									<td>
										<div class="form-row inline-pd" style="padding-right: 5px; padding-left: 5px;">
											<div class="col-10">
												<input type="text" class="form-control text-right" id="sale_model_out_rate" name="sale_model_out_rate" format="num" value="${saleRateList.sale_model_out_rate}" maxlength="6">
											</div>
											<div class="col-2">%</div>
										</div>
									</td>
								</tr>
								<tr>
									<th>계약 후 발주 모델</th>
									<td>
										<div class="form-row inline-pd" style="padding-right: 5px; padding-left: 5px;">
											<div class="col-10">
												<input type="text" class="form-control text-right" id="sale_order_model_rate" name="sale_order_model_rate" format="num" value="${saleRateList.sale_order_model_rate}" maxlength="6">
											</div>
											<div class="col-2">%</div>
										</div>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
				<!-- /중앙 폼테이블 -->
				<!-- 우측 폼테이블 - 판매추이증가 모델별 가중치 -->
				<div class="col-4">
					<div class="mb5">
						<div class="title-wrap mt5">
							<h4>판매추이증가 모델별 가중치</h4>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
						<div id="auiGridWeight" style="margin-top: 5px; height: 295px;"></div>
					</div>
				</div>
				<!-- 우측 폼테이블-->
			</div>
			<!-- /상단 폼테이블 -->
			<!-- 중앙 버튼 그룹 -->
			<div class="btn-group">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
				</div>
			</div>
			<!-- 하단 폼테이블 -->
			<div class="title-wrap">
				<h4>${sShortDt} 산출수량</h4>
			</div>
			<div id="auiGridCalc" style="margin-top: 5px;"></div>
			<!-- 최하단 버튼 그룹 -->
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
						<jsp:param name="pos" value="BOM_R"/>
					</jsp:include>
				</div>
			</div>
        </div>
		<!-- /컨텐츠 영역 -->
    </div>
	<!-- /팝업 -->
</form>
</body>
</html>
