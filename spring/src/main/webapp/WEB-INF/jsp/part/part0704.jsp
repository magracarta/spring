<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 부품판가산출지표 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-01-10 17:06:42
-- 실시간환율 1000번 제한, 위안화 제외
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid; // 산출구분표(메인) PART_OUTPUT_PRICE
		var auiGrids = [{auiGrid:{}, value:"PART_PRICE_MAKER", list:partPriceMakerJson}, // 메이커
						{auiGrid:{}, value:"PART_PRICE_DEALER_DISCOUNT", list:partPriceDealerDiscountJson}, // 딜러할인율
						{auiGrid:{}, value:"PART_PRICE_MNG_AMOUNT", list:partPriceMngAmountJson},  // 일반관리비
						{auiGrid:{}, value:"PART_PRICE_MARGIN", list:partPriceMarginJson}, // 마진율
						{auiGrid:{}, value:"PART_MARGIN", list:partApplyMarginJson}]; // 부품구분
		var examExcelGrid;
		var itemExcelGrid;

		var outputPriceCodeList = ${outputPriceCodeList} // 기준산출코드
		var partRealCheckArray = JSON.parse('${codeMapJsonObj['PART_REAL_CHECK']}'); // 실사구분
		var partCountryArray = JSON.parse('${codeMapJsonObj['PART_COUNTRY']}'); // 원산지
		var partMarginArray = JSON.parse('${codeMapJsonObj['PART_MARGIN']}'); // 부품구분

		var calcCodeList = ${calcCodeList}
		var rateList = ${rateList}  // 환율정보
		var ynList = [ {"code_value":"Y", "code_name" : "Y"}, {"code_value" :"", "code_name" :"N"}];
		<%-- 여기에 스크립트 넣어주세요. --%>
		$(document).ready(function() {
			createAUIGrid(); // 메인 그리드
			createExamGrid(); // 적용예시 엑셀 그리드 (hidden)
			createItemGrid(); // 적용품목 엑셀 그리드 (hidden)
			createAUIGridCalcCode(); // 기준산출코드 그리드
			for (var i = 0; i < auiGrids.length; ++i) {
				createLeftGrid(i); // 레프트 그리드
			}
			fnCreateAccordion();
			goSearch();

			console.log("calcCodeList : ", calcCodeList);
		});

		window.onresize = function() {
			for (var i = 0; i < auiGrids.length; ++i) {
				fnResizeGrid(i);
			}
			AUIGrid.resize(auiGrid);
		};

		// 통화별 환율결정 조회
		function goSearchRate() {
			$M.goNextPageAjax(this_page + "/price/search", '', '',
				function(result) {
					if(result.success) {
						for (var i = 0; i < result.list.length; ++i) {
							var cd = result.list[i].money_unit_cd;
							var basic = result.list[i].basic_er_price;
							var fixed = result.list[i].fixed_er_price;
							$M.setValue(cd+"_basic", basic);
							$M.setValue(cd+"_fixed", fixed);
						}
					};
				}
			);
		}

		// 환율동기화
		function goSyncExchangeRate() {
			$M.goNextPageAjax(this_page + "/syncExchangeRate", '', '',
				function(result) {
					if(result.success) {
						history.go(0);
					};
				}
			);
		}

		// 부품판가 조회
		function goSearch() {
			$M.goNextPageAjax("/part/part0704/PART_OUTPUT_PRICE/search", '', '',
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					}
				}
			);
		}

		// 산출구분표 그리드 생성
		function createAUIGrid() {
			var gridPros = {
				editable : true,
				// rowIdField 설정
				rowIdField : "_$uid",
				/* rowIdTrustMode : true, */
				//체크박스 출력 여부
				showRowCheckColumn: true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				showRowNumColumn: true,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				enableSorting : true,
				showStateColumn : true,
				fillColumnSizeMode : false
			};
			var columnLayout = [
				{
					dataField : "group_code",
					visible : false
				},
				{
					headerText : "명칭",
					dataField : "code_name",
					width : "25%",
					style : "aui-left aui-editable",
					required : true,
					editable : true,
					editRenderer : {
					      type : "InputEditRenderer",
					      // 에디팅 유효성 검사
					      max : 200,
					      validator : AUIGrid.commonValidator
					}
				},
				{
					headerText : "산출코드",
					dataField : "code",
					width : "8%",
					style : "aui-center aui-editable",
					required : true,
					editable : true,
					editRenderer : {
					      type : "InputEditRenderer",
					      // 에디팅 유효성 검사
					      length : 4,
					      auiGrid : "#PART_OUTPUT_PRICE",
					      cases : "upper",
					      validator : AUIGrid.commonValidator
					}
				},
				{
					headerText : "산출수식",
					dataField : "calc_foumular",
					style : "aui-left",
					width : "30%",
					editable : false
				},
				{
					// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
					// headerText : "대리점가율",
					headerText : "위탁판매점가율",
					dataField : "code_v1",
					width : "10%",
					dataType : "numeric",
					style : "aui-right aui-editable",
					editable : true,
					editRenderer : {
					    type : "InputEditRenderer",
					    onlyNumeric : true
					}
				},
				{
					headerText : "적용품목",
					dataField : "part_cnt",
					width : "8%",
					style : "aui-right",
					editable : false,
				},
				{
					headerText : "편집",
					dataField : "downloadBtn",
					width : "8%",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							fnDownloadExcel(event.item.code);
						},
					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						return '다운로드'
					},
					style : "aui-center",
					editable : false
				},
				{
					headerText : "삭제",
					dataField : "removeBtn",
					width : "8%",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							if (event.item.part_cnt != 0){
								alert("적용품목이 0개가 아닌 항목은 삭제할 수 없습니다.");
							} else {
								var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
								if (isRemoved == false) {
									AUIGrid.removeRow(event.pid, event.rowIndex);
								} else {
									AUIGrid.restoreSoftRows(auiGrid, "selectedIndex");
								};
							}
						},
					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false
				}
			];
			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#PART_OUTPUT_PRICE", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellEditBegin", function(event) {
				if(event.dataField == "code") {
					console.log(event.item);
					// 추가된 행 아이템인지 조사하여 추가된 행인 경우만 에디팅 진입 허용
					if(AUIGrid.isAddedById(event.pid, event.item._$uid)) {
						return true;
					} else {
						setTimeout(function() {
							   AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "조회된 코드는 수정할 수 없습니다.");
						}, 1);
						return false; // false 반환하면 기본 행위 안함(즉, cellEditBegin 의 기본행위는 에디팅 진입임)
					};
				}
				return true; // 다른 필드들은 편집 허용
			});
			AUIGrid.bind(auiGrid, "cellEditEndBefore", function(event) {
				   if (event.dataField == "code") {
					   var arr = [];
					   for (var i = 0; i < 4; i++){
						   var code = event.value.charAt(i).toUpperCase();
						   var name = AUIGrid.getItemsByValue(auiGrids[i].auiGrid, "code", code)[0];
						   // 저장하지 않은 row 제외
						   name != null && name != undefined && !AUIGrid.isAddedById(auiGrids[i].auiGrid, name._$uid) ? name = name.code_name : name = "";
						   arr.push(name);
					   };
					   var calc_foumular = arr[0]+" * "+arr[1]+" * 결정환율 * "+arr[2]+" / "+arr[3];
					   AUIGrid.updateRow(auiGrid, { "calc_foumular" : calc_foumular}, event.rowIndex);
					   return event.value.toUpperCase();
				   }
			});
		}

		// 코드 그리드들 생성
		function createLeftGrid(i) {
			// 그리드 속성 설정
			var gridPros = {
				rowIdField : "_$uid",
				//체크박스 출력 여부
				showRowCheckColumn: true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				showStateColumn : true,
				editable : true
			};
			// 메이커 제외하고 소수점 2자리 입력
			var isOnlyNumeric = false;
			var isAllowPoint = false;
			if (i != 0) {
				isOnlyNumeric = true;
				isAllowPoint = true;
			}
			var columnLayout = [
				{
					dataField : "group_code",
					visible : false
				},
				{
					dataField : "code",
					headerText : "코드",
					width : "20%",
					required : true,
					style : "aui-editable",
					editRenderer : {
					      type : "InputEditRenderer",
					      length : "1",
					      auiGrid : auiGrids[i].value,
					      cases : "upper",
					   	  // 에디팅 유효성 검사
					      validator : AUIGrid.commonValidator
					}
				},
				{
					dataField : "code_name",
					headerText : "적용값",
					width : "35%",
					style : "aui-editable",
					required : true,
					editRenderer : {
					    type : "InputEditRenderer",
					    onlyNumeric : isOnlyNumeric,
					    allowPoint : isAllowPoint // 소수점(.) 입력 가능 설정
					}
				},
				{
					dataField : "code_v1",
					headerText : "환율 통화",
					style : "aui-editable",
					width : "25%",
					required : i == 0 ? true : false,  // 메이커 코드관리일 경우에만 필수값.
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtn : false,
						showEditorBtnOver : false,
						list : rateList,
						keyField : "money_unit_cd",
						valueField : "money_unit_cd"
					},
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						for (var i = 0; i < rateList.length; ++i) {
							if (value == rateList[i].money_unit_cd) {
								return rateList[i].money_unit_cd;
							}
						}
					    return value;
					},
				},
				{
					width : "20%",
					headerText : "삭제",
					dataField : "removeBtn",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGrids[i].auiGrid, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);
							} else {
								AUIGrid.restoreSoftRows(auiGrids[i].auiGrid, "selectedIndex");
							};
						},
					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false
				}
			];
			// 23.10.30 부품구분 항목 추가
			if(i == 4){
				columnLayout = [
					{
						dataField : "group_code",
						visible : false
					},
					{
						dataField : "code",
						headerText : "코드",
						width : "10%",
						required : true,
						style : "aui-editable",
						editRenderer : {
							type : "InputEditRenderer",
							length : "1",
							auiGrid : auiGrids[i].value,
							cases : "upper",
							// 에디팅 유효성 검사
							validator : AUIGrid.commonValidator
						}
					},
					{
						dataField : "code_name",
						headerText : "구분",
						width : "25%",
						style : "aui-editable",
						required : true,
					},
					{
						dataField : "code_v1",
						headerText : "적용값",
						width : "20%",
						style : "aui-editable",
						required : true,
						editRenderer : {
							type : "InputEditRenderer",
							onlyNumeric : isOnlyNumeric,
							allowPoint : isAllowPoint // 소수점(.) 입력 가능 설정
						}
					},
					{
						dataField : "code_v2",
						headerText : "기본마진적용여부",
						style : "aui-editable",
						width : "25%",
						required : i == 0 ? true : false,  // 메이커 코드관리일 경우에만 필수값.
						editRenderer : {
							type : "DropDownListRenderer",
							showEditorBtn : false,
							showEditorBtnOver : false,
							list : ynList,
							keyField : "code_value",
							valueField : "code_name",
						},
						labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
							if (value != "" && value != null) {
								return value
							} else {
								return "N";
							}
						},
					},
					{
						width : "20%",
						headerText : "삭제",
						dataField : "removeBtn",
						renderer : {
							type : "ButtonRenderer",
							onClick : function(event) {
								var isRemoved = AUIGrid.isRemovedById(auiGrids[i].auiGrid, event.item._$uid);
								if (isRemoved == false) {
									AUIGrid.removeRow(event.pid, event.rowIndex);
								} else {
									AUIGrid.restoreSoftRows(auiGrids[i].auiGrid, "selectedIndex");
								};
							},
						},
						labelFunction : function(rowIndex, columnIndex, value,
												 headerText, item) {
							return '삭제'
						},
						style : "aui-center",
						editable : false
					}
				];
			}
			auiGrids[i].auiGrid = AUIGrid.create(auiGrids[i].value, columnLayout, gridPros);
			AUIGrid.setGridData(auiGrids[i].auiGrid, auiGrids[i].list);
			AUIGrid.bind(auiGrids[i].auiGrid, "cellEditEndBefore", function(event) {
			      if(event.dataField == "code") {
			    	  return event.value.toUpperCase(); // 대문자로 강제 조절하여 적용 시킴
			      }
			});
			
			AUIGrid.bind(auiGrids[i].auiGrid, "cellEditEnd", function( event ) {
				if(event.dataField == "code_v2" && event.value == "Y"){
					AUIGrid.updateRow(auiGrids[i].auiGrid, {code_v1 : "기본마진적용"}, event.rowIndex);
				} else if(event.dataField == "code_v2" && event.value == ""){
					AUIGrid.updateRow(auiGrids[i].auiGrid, {code_v1 : ""}, event.rowIndex);
				}
			});
			
			AUIGrid.bind(auiGrids[i].auiGrid, "cellEditBegin", function(event) {
				// 메이커 코드 그리드 아닐경우 에디팅 제어
				if (event.pid != "PART_PRICE_MAKER" && event.pid != "PART_MARGIN") {
					if (event.dataField == "code_v1") {
						return false;
					}
				}
				// 부품구분 그리드, 기본마진적용인 경우 적용값 에디팅 제어
				if (event.pid == "PART_MARGIN") {
					if (event.dataField == "code_v1" && event.item.code_v2 == "Y") {
						return false;
					}
				}

				if(event.dataField == "code") {
					// 추가된 행 아이템인지 조사하여 추가된 행인 경우만 에디팅 진입 허용
					if(AUIGrid.isAddedById(event.pid, event.item._$uid)) {
						return true;
					} else {
						setTimeout(function() {
							   AUIGrid.showToastMessage(auiGrids[i].auiGrid, event.rowIndex, event.columnIndex, "조회된 코드는 수정할 수 없습니다.");
						}, 1);
						return false; // false 반환하면 기본 행위 안함(즉, cellEditBegin 의 기본행위는 에디팅 진입임)
					};
				};
				return true; // 다른 필드들은 편집 허용
			});
		}

		// 한개만 펼쳐지는 아코디언
		function fnCreateAccordion() {
			var acc = document.getElementsByClassName("accordion-dev");
			var panel = document.getElementsByClassName('panel-dev');
			for (var i = 0; i < acc.length; i++) {
			    acc[i].onclick = function() {
			    	var fnSetClasses = !this.classList.contains('active');
			        fnSetClass(acc, 'active', 'remove');
			        fnSetClass(panel, 'show', 'remove');
			       	if (fnSetClasses) {
			            this.classList.toggle("active");
			            this.nextElementSibling.classList.toggle("show");
			        };
			    };
			};
		}

		// CSS 클래스 변경
		function fnSetClass(els, className, fnName) {
		    for (var i = 0; i < els.length; i++) {
		        els[i].classList[fnName](className);
		    };
		}

		// 코드 그리드 리사이즈
		function fnResizeGrid(i) {
			$("#"+auiGrids[i].auiGrid).css({ 'opacity': '0', 'visibility': 'hidden'});
			setTimeout(function() {
				AUIGrid.resize(auiGrids[i].auiGrid);
			}, 1);
			setTimeout(function() {
				$("#"+auiGrids[i].auiGrid).css({ 'opacity': '1', 'visibility': 'visible'});
			}, 10);
		}

		// 코드 행 추가, 삽입
		function fnAddCode(i) {
			var grid = auiGrids[i].auiGrid;
			console.log("grid : ", grid , " i ->  ", i);
	    	if(fnCheckGridEmpty(grid)) {
	    		var item = new Object();
	    		item.group_code = auiGrids[i].value;
	    		item.code_value = "";
	    		item.code_name = "";
	    		item.code_v1 = "";
				AUIGrid.addRow(grid, item, 'last');
	    	};
		}

		// 그리드 빈값 체크
		function fnCheckGridEmpty(auiId) {
			return AUIGrid.validation(auiId);
			//return AUIGrid.validateGridData(auiId, ["code", "code_name"], "필수 항목은 반드시 값을 입력해야합니다.");
		}

		// 산출구분표 행추가
		function fnAdd() {
			if(fnCheckGridEmpty(auiGrid)) {
	    		var item = new Object();
	    		item.group_code = "PART_OUTPUT_PRICE";
	    		item.code = "";
	    		item.code_name = "";
	    		item.code_desc = "";
	    		item.code_v1 = "";
	    		item.part_cnt = 0;
				AUIGrid.addRow(auiGrid, item, 'last');
				// $(window).scrollTop( $("#main_form").offset().top );
	    	};
		}

		// 부품코드 없으면 적용예시, 있으면 적용품목
		// 엑셀다운로드
		function fnDownloadExcel(partCode) {
			var url = "";
			var fileName = "";
			var queryString;
			var grid;
			// 부품코드가 없으면 적용예시 다운로드
			if (partCode === undefined) {
				url = this_page+"/apply/exam/search";
				grid = examExcelGrid;
				fileName = "적용예시";
				queryString = "";
			// 부품코드가 있으면 적용품목 다운로드
			} else {
				var param = {
					s_code : partCode
				};
				url = this_page+"/apply/item/search";
				grid = itemExcelGrid;
				fileName = "적용품목";
				queryString = $M.toGetParam(param);
			}
			$M.goNextPageAjax(url, queryString, '',
				function(result) {
					if(result.success) {
						console.log(result.list);
						AUIGrid.setGridData(grid, result.list);
						// 엑셀 내보내기 속성
						var exportProps = {};
					    fnExportExcel(grid, fileName, exportProps);
					}
				}
			);
		}

		// 적용예시 엑셀 다운로드그리드 생성
		function createExamGrid() {
			// 그리드 속성 설정
			var gridPros = {};
			var columnLayout = [
				{
					dataField : "part_no",
					headerText : "품번",
					width : "7%"
				},
				{
					dataField : "part_name",
					headerText : "품명",
					style : "aui-left",
					width : "18%"
				},
				{
					dataField : "part_new_no",
					headerText : "신번호"
				},
				{
					dataField : "part_output_price_cd",
					headerText : "산출구분"
				},
				{
					dataField : "list_price",
					headerText : "list price",
					style : "aui-right",
					dataType : "numeric"
				},
				{
					dataField : "net_price",
					headerText : "net price",
					style : "aui-right",
					dataType : "numeric"
				},
				{
					dataField : "in_stock_price",
					headerText : "입고단가",
					style : "aui-right",
					dataType : "numeric"
				},
				{
					dataField : "cust_price",
					headerText : "소비자가",
					style : "aui-right",
					dataType : "numeric"
				},
				{
					dataField : "mng_agency_price",
					// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
					// headerText : "대리점가",
					headerText : "위탁판매점가",
					style : "aui-right",
					dataType : "numeric"
				},
				{
					dataField : "dealer_discount",
					headerText : "딜러할인율",
					style : "aui-right",
					dataType : "numeric"
				},
				{
					dataField : "mng_amount",
					headerText : "관리비",
					style : "aui-right",
					dataType : "numeric"
				},
				{
					dataField : "amargin",
					headerText : "마진",
					style : "aui-right",
					dataType : "numeric"
				},
				{
					dataField : "exchange_rate",
					headerText : "환율",
					style : "aui-right",
					dataType : "numeric"
				},
				{
					dataField : "net_price_new",
					headerText : "net price(신)",
					style : "aui-right",
					dataType : "numeric"
				},
				{
					dataField : "buy_price_new",
					headerText : "입고단가(신)",
					dataType : "numeric",
					style : "aui-right"
				},
				{
					dataField : "customer_price_new",
					headerText : "소비자가(신)",
					dataType : "numeric",
					style : "aui-right"
				},
				{
					dataField : "customer_price_calc",
					headerText : "소비자가(신) 보정",
					dataType : "numeric",
					width : "7%",
					style : "aui-right"
				}
			];
			examExcelGrid = AUIGrid.create("examExcelGrid", columnLayout, gridPros);
		}

		// 그리드 다운로드 셀 - 적용 아이템 엑셀 다운로드그리드 생성
		function createItemGrid() {
			// 그리드 속성 설정
			var gridPros = {};
			var columnLayout = [
				{
					dataField : "codeid", // 문서에 code_id 로 돼있는거
					headerText : "부품번호",
				},
				{
					dataField : "part_nm",
					headerText : "품명",
					style : "aui-left",
				},
				{
					dataField : "part_new_no",
					headerText : "신번호"
				},
				{
					dataField : "part_old_no",
					headerText : "구형번호"
				},
				{
					dataField : "currentqty",
					headerText : "현재고",
					style : "aui-right",
					dataType : "numeric"
				},
				{
					dataField : "part_saf_stock",
					headerText : "안전재고",
					style : "aui-right",
					dataType : "numeric"
				},
				{
					dataField : "homi_qtyid",
					headerText : "총적정재고수량",
					style : "aui-right",
					dataType : "numeric"
				},
				{
					dataField : "maker_nm",
					headerText : "메이커"
				},
				{
					dataField : "deal_cus_name",
					headerText : "매입처"
				},
				{
					dataField : "product_gubun",
					headerText : "생산구분"
				},
				{
					dataField : "part_mng_cd",
					headerText : "관리구분"
				},
				{
					dataField : "part_mng_nm",
					headerText : "관리구분명"
				},
				{
					dataField : "part_id",
					headerText : "산출구분"
				},
				{
					dataField : "part_acins_gubun",
					headerText : "실사구분"
				},
				{
					dataField : "goods_item_cd",
					headerText : "부품구룹"
				},
				{
					dataField : "goods_item_nm",
					headerText : "그룹명"
				},
				{
					dataField : "forecast_yn",
					headerText : "수요예측자료여부"
				},
				{
					dataField : "homi_yn",
					headerText : "HOMI 관리품여부"
				},
				{
					dataField : "shipment_yn",
					headerText : "출하관리품여부"
				},
				{
					dataField : "service_exclude_yn",
					headerText : "정비지시서 제외여부"
				},
				{
					dataField : "curr_out_qty",
					headerText : "당해출고"
				},
				{
					dataField : "pre_out_qty",
					headerText : "전년출고"
				},
				{
					dataField : "before_pre_out_qty",
					headerText : "전전년출고"
				},
				{
					dataField : "part_new_no_cd",
					headerText : "신형번호호환성"
				},
				{
					dataField : "part_old_no_cd",
					headerText : "구형번호호환성"
				},
				{
					dataField : "list_price",
					headerText : "LIST PRICE"
				},
				{
					dataField : "net_price",
					headerText : "NET PRICE"
				},
				{
					dataField : "special_price",
					headerText : "SPECIAL"
				},
				{
					dataField : "in_price",
					headerText : "입고단가"
				},
				{
					dataField : "customer_price",
					headerText : "소비자가"
				},
				{
					dataField : "policy_price",
					headerText : "전략가"
				},
				{
					dataField : "dealer_price",
					// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
					// headerText : "대리점가"
					headerText : "위탁판매점가"
				},
				{
					dataField : "dealer_price2",
					// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
					// headerText : "대리점가2"
					headerText : "위탁판매점가2"
				},
				{
					dataField : "avg_in_price",
					headerText : "평균매입가"
				}
			];
			itemExcelGrid = AUIGrid.create("itemExcelGrid", columnLayout, gridPros);
		}

		// 체크 후 판가적용
		function goSave() {
			var rows = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if(rows.length == 0) {
				alert("체크된 항목이 없습니다.");
				return false;
			};
			var codes = [];
			for (var i = 0; i < rows.length; ++i) {
				codes.push(rows[i].code);
			};
			var param = {
					"code_str" : $M.getArrStr(codes)
			}
			$M.goNextPageAjaxMsg("모든 부품의 가격정보가 갱신됩니다. 적용 하시겠습니까?", this_page + "/apply/item/save", $M.toGetParam(param), {method : 'POST'},
				function(result) {
					if(result.success) {
						goSearch("PART_OUTPUT_PRICE");
					}
				}
			);
		}

		// 중복체크
		function goCheckDuplicate(grid, successFunc) {
			var arr1 = AUIGrid.getAddedRowItems(grid);
			if (arr1.length > 0) {
				var param = {
						"group_code_str" : $M.getArrStr(arr1, {key : "group_code"}),
						"code_str" : $M.getArrStr(arr1, {key : "code"})
				}
				$M.goNextPageAjax("/comm/comm9901", $M.toGetParam(param), '',
					function(result) {
						if(result.success) {
							successFunc();
						}
					}
				);
			} else {
				successFunc();
			}
		}

		// 산출구분표 변경사항 저장
		function goChangeSave() {
			var target = "PART_OUTPUT_PRICE";
			if (fnChangeGridDataCnt(auiGrid) == 0) {
				alert("변경된 데이터가 없습니다.");
				return false;
			};
			if (fnCheckGridEmpty(auiGrid) === false) {
				alert("필수 항목은 반드시 값을 입력해야합니다.");
				return false;
			};
			goCheckDuplicate(auiGrid, function(result) {
				var frm = fnChangeGridDataToForm(auiGrid);
				$M.goNextPageAjaxSave("/part/part0704/"+target+"/save", frm, {method : 'POST'},
					function(result) {
						if(result.success) {
							goSearch(target);
						}
					}
				);
			});
		}

		// 코드 그리드 저장
		function goSaveCode(i) {
			if (fnChangeGridDataCnt(auiGrids[i].auiGrid) == 0) {
				alert("변경된 데이터가 없습니다.");
				return false;
			};
			var grid = auiGrids[i].auiGrid;
			if(fnCheckGridEmpty(grid) === false) {
				alert("필수 항목은 반드시 값을 입력해야합니다.");
				return false;
			};
			goCheckDuplicate(auiGrids[i].auiGrid, function(result) {
				var frm = fnChangeGridDataToForm(auiGrids[i].auiGrid);
				console.log("frm : ", frm);
				$M.goNextPageAjaxSave("/part/part0704/"+auiGrids[i].value+"/save", frm, {method : 'POST'},
					function(result) {
						if(result.success) {
							AUIGrid.removeSoftRows(auiGrids[i].value);
							AUIGrid.resetUpdatedItems(auiGrids[i].value);
						}
					}
				);
			});
		}

		// 환율 저장
		function goSaveRate() {
			var arr = $('.money_unit_cd').map(function() {
			    return this.value;
			}).get();
			var basicArr = [];
			var fixArr = [];
			for (var i = 0; i < arr.length; ++i) {
				basicArr.push($M.getValue(arr[i]+"_basic"));
				fixArr.push($M.getValue(arr[i]+"_fixed"));
			}
			var param = {
					money_unit_cd_str :  arr.join("#"),
					fixed_er_price_str : fixArr.join("#"),
					basic_er_price_str : basicArr.join("#")
			}
			$M.goNextPageAjaxSave(this_page + "/price/save", $M.toGetParam(param), {method : 'POST'},
				function(result) {
					if(result.success) {
					}
				}
			);
		}

		// 환율경고설정 팝업 호출
		function goWarningExchangeRate() {
			var param = {

			};
			var popupOption = "";
			$M.goNextPage('/part/part0704p03', $M.toGetParam(param), {popupStatus : popupOption});
		}

		// 기준산출코드 그리드생성
		function createAUIGridCalcCode() {
			var gridPros = {
				rowIdField : "_$uid",
				// rowNumber
				showRowNumColumn: true,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				showStateColumn : true,
				editable : true,
				enableCellMerge : true
			};

			var columnLayout = [
				{
					headerText : "메이커",
					dataField : "code_name",
					width : "70",
					style : "aui-center",
					editable : false,
					cellMerge : true,
				},
				{
					dataField : "row_num",
					visible : false
				},
				{
					dataField : "maker_cd",
					visible : false
				},
				{
					dataField : "part_price_log_seq",
					visible : false
				},
				{
					dataField : "part_price_maker_cd",
					visible : false
				},
				{
					dataField : "part_production_cd",
					visible : false
				},
				{
					dataField : "part_price_dealer_discount",
					visible : false
				},
				{
					headerText : "생산구분",
					dataField : "part_production_name",
					width : "55",
					style : "aui-center",
					editable : false,
				},
				{
					headerText : "기준산출코드",
					dataField : "part_output_price_cd",
					width : "80",
					style : "aui-center aui-editable",
					editable : true,
					editRenderer : {
						type : "DropDownListRenderer",
						list : outputPriceCodeList,
						keyField : "code",
						valueField  : "code"
					},
				},
				{
					headerText : "실사구분",
					dataField : "part_real_check",
					width : "65",
					style : "aui-center aui-editable",
					editable : true,
					editRenderer : {
						type : "DropDownListRenderer",
						list : partRealCheckArray,
						keyField : "code_value",
						valueField  : "code_name"
					},
					labelFunction : function(rowIndex, columnIndex, value){
						for(var i=0; i<partRealCheckArray.length; i++){
							if(value == partRealCheckArray[i].code_value){
								return partRealCheckArray[i].code_name;
							}
						}
						return value;
					},
				},
				{
					headerText : "원산지",
					dataField : "part_country",
					width : "55",
					style : "aui-center aui-editable",
					editable : true,
					editRenderer : {
						type : "DropDownListRenderer",
						list : partCountryArray,
						keyField : "code_value",
						valueField  : "code_name"
					},
					labelFunction : function(rowIndex, columnIndex, value){
						for(var i=0; i<partCountryArray.length; i++){
							if(value == partCountryArray[i].code_value){
								return partCountryArray[i].code_name;
							}
						}
						return value;
					},
				},
				{
					headerText : "부품구분",
					dataField : "part_margin_cd",
					width : "65",
					style : "aui-center aui-editable",
					editable : true,
					editRenderer : {
						type : "DropDownListRenderer",
						list : partMarginArray,
						keyField : "code_value",
						valueField  : "code_value"
					},
				},
				{
					headerText : "관리구분",
					dataField : "part_mng_name",
					width : "65",
					style : "aui-center",
					editable : false,
				},
				{
					headerText : "기준환율",
					dataField : "basic_er_price",
					width : "65",
					dataType : "numeric",
					formatString : "#,##0.000",
					style : "aui-right",
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value){
						if (value == "0") {
							return "";
						} else {
							return value;
						}
					},
				},
				{
					headerText : "결정환율",
					dataField : "fixed_er_price",
					width : "65",
					dataType : "numeric",
					formatString : "#,##0.000",
					style : "aui-right",
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value){
						if (value == "0") {
							return "";
						} else {
							return value;
						}
					},
				},
				{
					headerText : "관리비",
					dataField : "part_price_mng_amount",
					width : "55",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value){
						if (value == "0") {
							return "";
						} else {
							return value;
						}
					},
				},
				{
					headerText : "마진",
					dataField : "part_price_margin",
					width : "55",
					dataType : "numeric",
					formatString : "#,##0.000",
					style : "aui-right",
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value){
						if (value == "0") {
							return "";
						} else {
							return value;
						}
					},
				},
				{
					headerText : "기본 판가 수식",
					dataField : "part_output_price_name",
					width : "165",
					style : "aui-left",
					editable : false,
				},
				{
					headerText : "Net Price",
					dataField : "net_price",
					width : "70",
					dataType : "numeric",
					headerStyle : 'aui-fold',
					formatString : "#,##0",
					style : "aui-right aui-editable",
					editable : true,
					labelFunction : function(rowIndex, columnIndex, value){
						if (value == "0") {
							return "";
						} else {
							return $M.setComma(value);
						}
					},
				},
				{
					headerText : "A : 판매가",
					dataField : "vip_price",
					width : "70",
					dataType : "numeric",
					headerStyle : 'aui-fold',
					formatString : "#,##0",
					style : "aui-right",
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value){
						if (value == "0") {
							return "";
						} else {
							return $M.setComma(value);
						}
					},
				},
				{
					headerText : "마진",
					dataField : "vip_margin_price",
					width : "55",
					dataType : "numeric",
					headerStyle : 'aui-fold',
					formatString : "#,##0",
					style : "aui-right",
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value){
						if (value == "0") {
							return "";
						} else {
							return $M.setComma(value);
						}
					},
				},
				{
					headerText : "B : 일반판매가",
					dataField : "sale_price",
					width : "95",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value){
						if (value == "0") {
							return "";
						} else {
							return $M.setComma(value);
						}
					},
				},
				{
					headerText : "마진",
					dataField : "sale_margin_price",
					width : "60",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value){
						if (value == "0") {
							return "";
						} else {
							return $M.setComma(value);
						}
					},
				},
				{
					headerText : "%",
					dataField : "margin_rate",
					width : "45",
					dataType : "numeric",
// 					postfix: "%",
					formatString : "#,##0",
					style : "aui-right",
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value){
						if (value == "0") {
							return "";
						} else {
							return value + "%";
						}
					},
				},
				{
					headerText : "B-A",
					dataField : "cal_price",
					width : "75",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value){
						if (value == "0") {
							return "";
						} else {
							return $M.setComma(value);
						}
					},
				},
			];

			auiGridCalcCode = AUIGrid.create("#auiGridCalcCode", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridCalcCode, ${calcCodeList});

			// NET PRICE 입력시 validation
			AUIGrid.bind(auiGridCalcCode, "cellEditEndBefore", function(event) {
				if(event.dataField == "net_price") {
					if (event.item.part_output_price_cd == "") {
						setTimeout(function() {
							   AUIGrid.showToastMessage(auiGridCalcCode, event.rowIndex, event.columnIndex, "기준산출코드를 먼저 선택해주세요.");
						}, 1);
						if (event.oldValue == null) {
							return "";
						} else {
							return event.oldValue;
						}
					}
				}
			});

			AUIGrid.bind(auiGridCalcCode, "cellEditEnd", function(event) {
				console.log("event : ", event);

				// 기준산출코드
// 				if (event.dataField == "part_output_price_cd") {
// 					var item = {
// 							"net_price" : 0,
// 							"vip_price" : 0,
// 							"vip_margin_price" : 0,
// 							"sale_price" : 0,
// 							"sale_margin_price" : 0,
// 							"margin_rate" : 0,
// 							"cal_price" : 0
// 					}
// 					AUIGrid.updateRow(auiGridCalcCode, item, event.rowIndex);


// 					var partPriceMngAmountVal; // 관리비
// 					var partPriceMarginVal; // 마진
// 					var basicErPriceVal; // 기준환율
// 					var fixedErPriceVal; // 결정환율

// 					var param = {
// 							maker_code : event.item.part_output_price_cd.substr(0, 1),
// 							code_value : event.item.maker_cd
// 					}

// 					$M.goNextPageAjax(this_page + "/partMaker/search", $M.toGetParam(param), {method : 'GET'},
// 						function(result) {
// 				    		if(result.success) {
// 				    			var moneyUnitCdVal; // 환율을 구하기위한 통화

// 								// 국산일경우 money_unit_cd = KRW 고정
// 								if (event.item.part_production_name == '국산') {
// 									moneyUnitCdVal = 'KRW';
// 								} else {
// 									moneyUnitCdVal = result.money_unit_cd;
// 								}

// 		 						for (var i = 0; i < rateList.length; i++) {
// 		 							if (rateList[i].money_unit_cd == moneyUnitCdVal) {
// 		 								fixedErPriceVal = rateList[i].fixed_er_price;
// 		 								basicErPriceVal = rateList[i].basic_er_price;
// 		 							}
// 		 						}

// 								// 메이커가 '기타'일 경우 환율 0
// 		 						if (event.item.code_name == '기타') {
// 	 								fixedErPriceVal = 0;
// 	 								basicErPriceVal = 0;
// 		 						}

// 		 		    			var param = {
// 		 		    					part_price_maker_cd : result.part_price_maker_cd,
// 		 		    					basic_er_price : basicErPriceVal,
// 		 		    					fixed_er_price : fixedErPriceVal
// 		 		    			}

// 				    			AUIGrid.updateRow(auiGridCalcCode, param, event.rowIndex);
// 							}
// 						}
// 					);

// 					for (var i = 0; i < outputPriceCodeList.length; i++) {
// 						if (event.item.part_output_price_cd == outputPriceCodeList[i].code) {
// 							console.log("outputPriceCodeList[i] : ", outputPriceCodeList[i]);
// 							var param = {
// 									"part_output_price_name" : outputPriceCodeList[i].calc_foumular,  // 기본 판가수식
// 									"part_price_dealer_discount" : outputPriceCodeList[i].dealer_cd_name,	// 딜러할인율
// 									"part_price_mng_amount" : outputPriceCodeList[i].mng_cd_name,	// 관리비
// 									"part_price_margin" : outputPriceCodeList[i].margin_cd_name,	// 마진
// 							}

// 							partPriceMngAmountVal = outputPriceCodeList[i].mng_cd_name;
// 							partPriceMarginVal = outputPriceCodeList[i].margin_cd_name;
// 							AUIGrid.updateRow(auiGridCalcCode, param, event.rowIndex);
// 						}
// 					}

// 					var netPrice = event.item.net_price;
// 					var fixedErPrice = fixedErPriceVal;
// 					var partPriceMngAmount = partPriceMngAmountVal;
// 					var partPriceMargin = partPriceMarginVal;

// // 					fnCalcVipPrice(netPrice, fixedErPrice, partPriceMngAmount, partPriceMargin, event.rowIndex);
// 				}

				// 수정본
				if (event.dataField == "part_output_price_cd") {
// 					var item = {
// 							"net_price" : 0,
// 							"vip_price" : 0,
// 							"vip_margin_price" : 0,
// 							"sale_price" : 0,
// 							"sale_margin_price" : 0,
// 							"margin_rate" : 0,
// 							"cal_price" : 0
// 					}
// 					AUIGrid.updateRow(auiGridCalcCode, item, event.rowIndex);


					var partPriceMngAmountVal; // 관리비
					var partPriceMarginVal; // 마진
// 					var basicErPriceVal; // 기준환율
					var fixedErPriceVal; // 결정환율

					var codeValue = event.value.substr(0,1);
					var param = {
							code_value : codeValue
					};

					$M.goNextPageAjax(this_page + "/getExchangeRate", $M.toGetParam(param), {method : 'GET'},
						function(result) {
				    		if(result.success) {

			    				var list = result.exRateInfo;  // 메이커 코드에따른 환율 정보
			    				console.log("list : ", list);

			    				var data = {
			    						part_price_maker_cd : codeValue
			    				};

								if (event.item.part_production_name == '국산') {
// 				    				basicErPriceVal = 1;
				    				fixedErPriceVal = 1;
									data.basic_er_price = 1;
									data.fixed_er_price = 1;
								} else {
// 				    				basicErPriceVal = list[0].basic_er_price;
				    				fixedErPriceVal = list[0].fixed_er_price;
									data.basic_er_price = list[0].basic_er_price;
									data.fixed_er_price = list[0].fixed_er_price;
								}

								AUIGrid.updateRow(auiGridCalcCode, data, event.rowIndex);

								for (var i = 0; i < outputPriceCodeList.length; i++) {
									if (event.item.part_output_price_cd == outputPriceCodeList[i].code) {
										console.log("outputPriceCodeList[i] : ", outputPriceCodeList[i]);
										var param = {
												"part_output_price_name" : outputPriceCodeList[i].calc_foumular,  // 기본 판가수식
												"part_price_dealer_discount" : outputPriceCodeList[i].dealer_cd_name,	// 딜러할인율
												"part_price_mng_amount" : outputPriceCodeList[i].mng_cd_name,	// 관리비
												"part_price_margin" : outputPriceCodeList[i].margin_cd_name,	// 마진
										}

										partPriceMngAmountVal = outputPriceCodeList[i].mng_cd_name;
										partPriceMarginVal = outputPriceCodeList[i].margin_cd_name;
										AUIGrid.updateRow(auiGridCalcCode, param, event.rowIndex);
									}
								}

								var netPrice = event.item.net_price;
								var fixedErPrice = fixedErPriceVal;
								var partPriceMngAmount = partPriceMngAmountVal;
								var partPriceMargin = partPriceMarginVal;
								var partMarginCd = event.item.part_margin_cd;
								
								console.log("netPrice : ", netPrice);
								console.log("fixedErPrice : ", fixedErPrice);
								console.log("partPriceMngAmount : ", partPriceMngAmount);
								console.log("partPriceMargin : ", partPriceMargin);

								fnCalcVipPrice(netPrice, fixedErPrice, partPriceMngAmount, partPriceMargin, partMarginCd, event.rowIndex);
							}
						}
					);
				}

				// net price 입력시 A: 판매가, 마진 세팅
				if (event.dataField == "net_price") {
					var partPriceVipRate = $M.getValue("part_price_vip_rate");
					if ($M.getValue("part_price_vip_rate") == "" || $M.getValue("part_price_vip_rate") == "0") {
						alert("비율을 입력해주세요.");
						return false;
					}

					console.log("event : ", event);

					// 기준산출코드, 원산지 선택후 가능하도록.
					// NET PRICE, 결정환율, 일반관리비, 마진율 파라미터로 넘길것.
					var netPrice = event.item.net_price;
					var fixedErPrice = event.item.fixed_er_price;
					var partPriceMngAmount = event.item.part_price_mng_amount;
					var partPriceMargin = event.item.part_price_margin;
					var partMarginCd = event.item.part_margin_cd;

					fnCalcVipPrice(netPrice, fixedErPrice, partPriceMngAmount, partPriceMargin, partMarginCd, event.rowIndex);

				}
				// 부품구분 변경 시 
				if (event.dataField == "part_margin_cd") {
					if ($M.getValue("part_price_vip_rate") == "" || $M.getValue("part_price_vip_rate") == "0") {
						alert("비율을 입력해주세요.");
						return false;
					}

					// 기준산출코드, 원산지 선택후 가능하도록.
					// NET PRICE, 결정환율, 일반관리비, 마진율, 부품구분 파라미터로 넘길것.
					var netPrice = event.item.net_price;
					var fixedErPrice = event.item.fixed_er_price;
					var partPriceMngAmount = event.item.part_price_mng_amount;
					var partPriceMargin = event.item.part_price_margin;
					var partMarginCd = event.item.part_margin_cd;

					fnCalcVipPrice(netPrice, fixedErPrice, partPriceMngAmount, partPriceMargin, partMarginCd, event.rowIndex);

				}
			});

		}

		// VIP PRICE 구하기 및 일반판매가 구하기
		function fnCalcVipPrice(netPrice, fixedErPrice, partPriceMngAmount, partPriceMargin, partMarginCd, rowIndex) {
// 			console.log("netPrice : ", netPrice);
// 			console.log("fixedErPrice : ", fixedErPrice);
// 			console.log("partPriceMngAmount : ", partPriceMngAmount);
// 			console.log("partPriceMargin : ", partPriceMargin);

			if (netPrice != 0 || netPrice != "") {
				var param = {
						"net_price" : netPrice,
						"fixed_er_price" : fixedErPrice,
						"mng_amount" : partPriceMngAmount,
						"margin" : partPriceMargin,
						"part_margin_cd" : partMarginCd,
						"part_price_vip_rate" : $M.getValue("part_price_vip_rate")
				}

				$M.goNextPageAjax(this_page + "/vipPrice/search", $M.toGetParam(param), {method : 'GET'},
					function(result) {
			    		if(result.success) {
	 		    			console.log(result);

	 		    			var param = {
	 		    					"vip_price" : result.vip_price,
	 		    					"vip_margin_price" : result.margin_price,
	 		    					"sale_price" : result.cust_price,
	 		    					"sale_margin_price" : result.sale_margin_price,
	 		    					"margin_rate" : result.margin_rate,
	 		    					"cal_price" : result.cal_price
	 		    			}

			    			AUIGrid.updateRow(auiGridCalcCode, param, rowIndex);
						}
					}
				);
			}
		}

		// 비율 적용
		function goApplyRatio() {
			var partPriceVipRate = $M.getValue("part_price_vip_rate");
			if ($M.getValue("part_price_vip_rate") == "" || $M.getValue("part_price_vip_rate") == "0") {
				alert("비율을 입력해주세요.");
				return false;
			}

			if (confirm("일반판매가를 적용하시겠습니까?") == false) {
				return false;
			}

			var gridData = AUIGrid.getGridData(auiGridCalcCode);
			var frm = document.main_form;
			frm = $M.toValueForm(frm);

			var rowNumArr = [];
			var fixedErPriceArr = [];
			var partPriceMngAmountArr = [];
			var netPriceArr = [];
			var vipPriceArr = [];
			var partOutputPriceCdArr = [];

			for (var i = 0; i < gridData.length; i++) {
				rowNumArr.push(gridData[i].row_num);
				fixedErPriceArr.push(gridData[i].fixed_er_price);
				partPriceMngAmountArr.push(gridData[i].part_price_mng_amount);
				netPriceArr.push(gridData[i].net_price);
				vipPriceArr.push(gridData[i].vip_price);
				partOutputPriceCdArr.push(gridData[i].part_output_price_cd);
			}

			var option = {
					isEmpty : true
			};

			$M.setValue(frm, "row_num_str", $M.getArrStr(rowNumArr, option));
			$M.setValue(frm, "fixed_er_price_str", $M.getArrStr(fixedErPriceArr, option));
			$M.setValue(frm, "part_price_mng_amount_str", $M.getArrStr(partPriceMngAmountArr, option));
			$M.setValue(frm, "net_price_str", $M.getArrStr(netPriceArr, option));
			$M.setValue(frm, "vip_price_str", $M.getArrStr(vipPriceArr, option));
			$M.setValue(frm, "part_output_price_cd_str", $M.getArrStr(partOutputPriceCdArr, option));

			$M.goNextPageAjax(this_page + "/custPrice/search", frm, {method : 'GET'},
				function(result) {
		    		if(result.success) {
 		    			console.log(result);

 		    			var list = result.list;

 		    			for (var i = 0; i < list.length; i++) {
	 		    			var param = {
	 		    					"sale_price" : list[i].cust_price,
	 		    					"sale_margin_price" : list[i].sale_margin_price,
	 		    					"margin_rate" : list[i].margin_rate,
	 		    					"cal_price" : list[i].cal_price
	 		    			}

	 		    			if (list[i].cust_price != 0) {
				    			AUIGrid.updateRow(auiGridCalcCode, param, i);
	 		    			}
 		    			}
					}
				}
			);

		}

		// history 팝업 호출
		function goCalcCodeHistory() {
			var param = {

				};
			var popupOption = "";
			$M.goNextPage('/part/part0704p01', $M.toGetParam(param), {popupStatus : popupOption});
		}

		// 기준산출코드 변경내용 저장
		function goSaveCalcCode() {
			var frm = document.main_form;
			frm = $M.toValueForm(frm);

			var gridData = AUIGrid.getGridData(auiGridCalcCode);
			var changeGridData = AUIGrid.getEditedRowItems(auiGridCalcCode); // 변경내역

			for (var i = 0; i < changeGridData.length; i++) {
				var item = changeGridData[i];
				if (item.part_price_maker_cd == "" || item.part_production_cd == "" || item.part_output_price_cd == "" || item.part_output_price_name == "" ||
						item.part_real_check == "" || item.part_country == "") {
					alert("수정된 행의 기준산출코드, 실사구분, 원산지 입력은 필수입니다.");
					return false;
				}
			}

			if (confirm("변경사항을 저장하시겠습니까?") == false) {
				return false;
			}

			var rowNumArr = [];
			var partPriceVipRate = $M.getValue("part_price_vip_rate");
			var makerCdArr = [];
			var partPriceMakerCdArr = [];
			var partProductionCdArr = [];
			var partOutputPriceCdArr = [];
			var partOutputPriceNameArr = [];
			var partRealCheckArr = [];
			var partCountryArr = [];
			var partPriceDealerDiscountArr = [];
			var basicErPriceArr = [];
			var fixedErPriceArr = [];
			var partPriceMngAmountArr = [];
			var partPriceMarginArr = [];
			var netPriceArr = [];
			var vipPriceArr = [];
			var vipMarginPriceArr = [];
			var salePriceArr = [];
			var saleMarginPriceArr = [];
			var marginRateArr = [];
			var partMarginCdArr = [];

			for (var i = 0; i < gridData.length; i++) {
				if (gridData[i].part_output_price_cd != "" || gridData[i].part_real_check != "" || gridData[i].part_country != "") {
					rowNumArr.push(gridData[i].row_num);
					makerCdArr.push(gridData[i].maker_cd);
					partPriceMakerCdArr.push(gridData[i].part_price_maker_cd);
					partProductionCdArr.push(gridData[i].part_production_cd);
					partOutputPriceCdArr.push(gridData[i].part_output_price_cd);
					partOutputPriceNameArr.push(gridData[i].part_output_price_name);
					partRealCheckArr.push(gridData[i].part_real_check);
					partCountryArr.push(gridData[i].part_country);
					partPriceDealerDiscountArr.push(gridData[i].part_price_dealer_discount);
					basicErPriceArr.push(gridData[i].basic_er_price);
					fixedErPriceArr.push(gridData[i].fixed_er_price);
					partPriceMngAmountArr.push(gridData[i].part_price_mng_amount);
					partPriceMarginArr.push(gridData[i].part_price_margin);
					netPriceArr.push(gridData[i].net_price);
					vipPriceArr.push(gridData[i].vip_price);
					vipMarginPriceArr.push(gridData[i].vip_margin_price);
					salePriceArr.push(gridData[i].sale_price);
					saleMarginPriceArr.push(gridData[i].sale_margin_price);
					marginRateArr.push(gridData[i].margin_rate);
					partMarginCdArr.push(gridData[i].part_margin_cd);
				}
			}

			var option = {
					isEmpty : true
			};

			$M.setValue(frm, "row_num_str", $M.getArrStr(rowNumArr, option));
			$M.setValue(frm, "maker_cd_str", $M.getArrStr(makerCdArr, option));
			$M.setValue(frm, "part_price_maker_cd_str", $M.getArrStr(partPriceMakerCdArr, option));
			$M.setValue(frm, "part_production_cd_str", $M.getArrStr(partProductionCdArr, option));
			$M.setValue(frm, "part_output_price_cd_str", $M.getArrStr(partOutputPriceCdArr, option));
			$M.setValue(frm, "part_output_price_name_str", $M.getArrStr(partOutputPriceNameArr, option));
			$M.setValue(frm, "part_real_check_str", $M.getArrStr(partRealCheckArr, option));
			$M.setValue(frm, "part_country_str", $M.getArrStr(partCountryArr, option));
			$M.setValue(frm, "part_price_dealer_discount_str", $M.getArrStr(partPriceDealerDiscountArr, option));
			$M.setValue(frm, "basic_er_price_str", $M.getArrStr(basicErPriceArr, option));
			$M.setValue(frm, "fixed_er_price_str", $M.getArrStr(fixedErPriceArr, option));
			$M.setValue(frm, "part_price_mng_amount_str", $M.getArrStr(partPriceMngAmountArr, option));
			$M.setValue(frm, "part_price_margin_str", $M.getArrStr(partPriceMarginArr, option));
			$M.setValue(frm, "net_price_str", $M.getArrStr(netPriceArr, option));
			$M.setValue(frm, "vip_price_str", $M.getArrStr(vipPriceArr, option));
			$M.setValue(frm, "vip_margin_price_str", $M.getArrStr(vipMarginPriceArr, option));
			$M.setValue(frm, "sale_price_str", $M.getArrStr(salePriceArr, option));
			$M.setValue(frm, "sale_margin_price_str", $M.getArrStr(saleMarginPriceArr, option));
			$M.setValue(frm, "margin_rate_str", $M.getArrStr(marginRateArr, option));
			$M.setValue(frm, "part_margin_cd_str", $M.getArrStr(partMarginCdArr, option));

			console.log("frm : ", frm);

			$M.goNextPageAjax(this_page + "/calcCode/save", frm, {method : 'POST'},
				function(result) {
					if(result.success) {
						location.reload();
					}
				}
			);
		}

// 		function fnCheckGridEmpty() {
// 			return AUIGrid.validateGridData(auiGridCalcCode, ["part_price_maker_cd", "part_production_cd", "part_output_price_cd", "part_output_price_name", "part_real_check", "part_country"], "필수 항목은 반드시 값을 입력해야합니다.");
// 		}

		// 최신환율적용
		function goRefreshExchangeRate() {
			var param = {};

			$M.goNextPageAjax(this_page + "/getExchangeRate", $M.toGetParam(param), {method : 'GET'},
				function(result) {
		    		if(result.success) {
	    				console.log("result : ", result);

	    				var list = result.exRateInfo;  // 메이커 코드에따른 환율 정보
						var gridData = AUIGrid.getGridData(auiGridCalcCode);
						console.log("gridData : ", gridData);

						for (var i = 0; i < gridData.length; i++) {
							var str = gridData[i].part_output_price_cd.substring(0, 1); // 산출코드의 첫자리
							var partProductionName = gridData[i].part_production_name; // 생산구분 (순정/국산)

							for (var j = 0; j < list.length; j++) {
								if (list[j].code == str) {
									var data = {} // 기준환율, 결정환율 데이터를 담을 객체

									if (partProductionName == "국산") {
										// 국산일경우 1
										data.basic_er_price = 1;
										data.fixed_er_price = 1;
									} else {
										data.basic_er_price = list[j].basic_er_price;
										data.fixed_er_price = list[j].fixed_er_price
									}

									AUIGrid.updateRow(auiGridCalcCode, data, i);
								}
							}
						}
					}

					// TODO : 변경된 환율로 가격 다시 계산.

					var gData = AUIGrid.getGridData(auiGridCalcCode);
					console.log("변경된 gridData : ", gData);
					for (var i = 0; i < gData.length; i++) {
						var netPrice = gData[i].net_price;
						var fixedErPrice = gData[i].fixed_er_price;
						var partPriceMngAmount = gData[i].part_price_mng_amount;
						var partPriceMargin = gData[i].part_price_margin;
						var partMarginCd = gData[i].part_margin_cd;

						fnCalcVipPrice(netPrice, fixedErPrice, partPriceMngAmount, partPriceMargin, partMarginCd, i);
					}
				}
			);

		}

	</script>
</head>
<body>
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
	<div class="content-wrap">
		<div class="content-box">
	<!-- 메인 타이틀 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
	<!-- /메인 타이틀 -->
			<div class="contents">
				<div class="row">
					<div class="col-12">
						<div class="title-wrap mt10">
							<h4>기준산출코드 - 시뮬레이션</h4>
							<div class="btn-group">
								<div class="right">
		<%-- 						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include> --%>
<!-- 									<button type="button" class="btn btn-default" onclick="javascript:fnAddCalcCode()"><i class="material-iconsadd text-default"></i>메이커 추가</button> -->
									<button type="button" class="btn btn-default" onclick="javascript:goRefreshExchangeRate()"><i class="material-iconsdone text-default"></i>최신환율적용</button>
									일반판매가 산출 비율
									<input type="text" id="part_price_vip_rate" name="part_price_vip_rate" style="width : 70px" value="${lastVipRate}">
									<button type="button" class="btn btn-default" onclick="javascript:goApplyRatio()"><i class="material-iconsdone text-default"></i>적용</button>
								</div>
							</div>
						</div>
						<div id="auiGridCalcCode" style="margin-bottom: 5px; margin-top: 5px; height: 350px;"></div>
					</div>
				</div>
				<div class="btn-group">
					<div class="right">
						<button type="button" class="btn btn-info" onclick="javascript:goSaveCalcCode()" style="margin-bottom: 5px;">기준 산출코드 변경내용 저장</button>
						<button type="button" class="btn btn-info" onclick="javascript:goCalcCodeHistory()" style="margin-bottom: 5px;">기준 산출코드 History</button>
					</div>
				</div>
					<div class="row">
						<div class="col-4">
<!-- 아코디언 패널 -->
							<div class="row-accordion connected">
<!-- Maker -->
								<div class="row boxing pd0 accordion-dev active" >
									<div class="col-12 boxing-header" onclick="javascript:fnResizeGrid(0)">
										<div>Maker</div>
										<div><i class="material-iconsexpand_less"></i></div>
									</div>
								</div>
								<div class="row boxing mt-9 panel-dev show">
									<div class="col-12 boxing-body">
										<div class="title-wrap">
											<h4>메이커 코드관리</h4>
											<button type="button" class="btn btn-default" onclick="javascript:fnAddCode(0)"><i class="material-iconsadd text-default"></i> 행추가</button>
										</div>
										<div id="PART_PRICE_MAKER" style="margin-top: 5px; height: 200px;" ></div>
										<div class="btn-group mt5">
											<div class="right">
												<button type="button" class="btn btn-info" onclick="javascript:goSaveCode(0)">저장</button>
											</div>
										</div>
									</div>
								</div>
<!-- /Maker -->
<!-- 딜러할인율 -->
								<div class="row boxing pd0 accordion-dev">
									<div class="col-12 boxing-header" onclick="javascript:fnResizeGrid(1)">
										<div>딜러할인율</div>
										<div><i class="material-iconsexpand_more"></i></div>
									</div>
								</div>
								<div class="row boxing mt-9 panel-dev" >
									<div class="col-12 boxing-body">
										<div class="title-wrap">
											<h4>딜러할인율 코드관리</h4>
											<button type="button" class="btn btn-default" onclick="javascript:fnAddCode(1)"><i class="material-iconsadd text-default"></i> 행추가</button>
										</div>
										<div id="PART_PRICE_DEALER_DISCOUNT" style="margin-top: 5px; height: 200px;" ></div>
										<div class="btn-group mt5">
											<div class="right">
												<button type="button" class="btn btn-info" onclick="javascript:goSaveCode(1)">저장</button>
											</div>
										</div>
									</div>
								</div>
<!-- /딜러할인율 -->
<!-- 일반관리비 -->
								<div class="row boxing pd0 accordion-dev">
									<div class="col-12 boxing-header" onclick="javascript:fnResizeGrid(2)">
										<div>일반관리비</div>
										<div><i class="material-iconsexpand_more"></i></div>
									</div>
								</div>
								<div class="row boxing mt-9 panel-dev" >
									<div class="col-12 boxing-body">
										<div class="title-wrap">
											<h4>일반관리비 코드관리</h4>
											<button type="button" class="btn btn-default" onclick="javascript:fnAddCode(2)"><i class="material-iconsadd text-default"></i> 행추가</button>
										</div>
										<div id="PART_PRICE_MNG_AMOUNT" style="margin-top: 5px; height: 200px" ></div>
										<div class="btn-group mt5">
											<div class="right">
												<button type="button" class="btn btn-info" onclick="javascript:goSaveCode(2)">저장</button>
											</div>
										</div>
									</div>
								</div>
<!-- /일반관리비 -->
<!-- 마진율 -->
								<div class="row boxing pd0 accordion-dev">
									<div class="col-12 boxing-header" onclick="javascript:fnResizeGrid(3)" >
										<div>마진율</div>
										<div><i class="material-iconsexpand_more"></i></div>
									</div>
								</div>
								<div class="row boxing mt-9 panel-dev">
									<div class="col-12 boxing-body">
										<div class="title-wrap">
											<h4>마진율 코드관리</h4>
											<button type="button" class="btn btn-default" onclick="javascript:fnAddCode(3)"><i class="material-iconsadd text-default"></i> 행추가</button>
										</div>
										<div id="PART_PRICE_MARGIN" style="margin-top: 5px; height : 200px;" ></div>
										<div class="btn-group mt5">
											<div class="right">
												<button type="button" class="btn btn-info" onclick="javascript:goSaveCode(3)">저장</button>
											</div>
										</div>
									</div>
								</div>
<!-- /마진율 -->
<!-- 부품구분 -->
								<div class="row boxing pd0 accordion-dev">
									<div class="col-12 boxing-header" onclick="javascript:fnResizeGrid(4)" >
										<div>부품구분</div>
										<div><i class="material-iconsexpand_more"></i></div>
									</div>
								</div>
								<div class="row boxing mt-9 panel-dev">
									<div class="col-12 boxing-body">
										<div class="title-wrap">
											<h4>부품구분 마진율 적용</h4>
											<button type="button" class="btn btn-default" onclick="javascript:fnAddCode(4)"><i class="material-iconsadd text-default"></i> 행추가</button>
										</div>
										<div id="PART_MARGIN" style="margin-top: 5px; height : 200px;" ></div>
										<div class="btn-group mt5">
											<div class="right">
												<button type="button" class="btn btn-info" onclick="javascript:goSaveCode(4)">저장</button>
											</div>
										</div>
									</div>
								</div>
<!-- /부품구분 -->
							</div>
<!-- /아코디언 패널 -->
<!-- 통화별 환율결정 -->
							<div class="title-wrap mt10">
								<h4>통화별 환율결정</h4>
								<div class="right">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_L"/></jsp:include>
								</div>
								<div class="text-warning">※ 메이커 코드관리의 환율 통화에 따라 환율이 적용</div>
							</div>
							<table class="table-border mt5">
								<colgroup>
									<col width="100px">
									<col width="">
									<col width="">
								</colgroup>
								<thead>
									<tr>
										<th class="title-bg">통화</th>
										<th class="title-bg">기준환율
											<c:if test="${not empty syncDate }">
												<br><a href="https://www.koreaexim.go.kr/site/program/financial/exchange?menuid=001001004002001" target="_blank" style="font-size: 11px;color: blue">(한국수출입은행 ${syncDate})</a>
											</c:if>
										</th>
										<th class="title-bg">결정환율</th>
									</tr>
								</thead>
								<tbody>
									<c:forEach var="item" items="${list}">
										<tr>
											<th style="width:100px; background: #efefef !important">
												${item.money_unit_cd}
												<input type="hidden" class="money_unit_cd input-div" value="${item.money_unit_cd}" disabled="disabled" style="background: #efefef !important">
											</th>
											<td class="text-right">
												<input type="text" class="form-control text-right" format="decimal" id="${item.money_unit_cd}_basic" name="${item.money_unit_cd}_basic" maxlength="8" value="${item.basic_er_price}">
											</td>
											<td>
												<input type="text" class="form-control text-right" format="decimal" id="${item.money_unit_cd}_fixed" name="${item.money_unit_cd}_fixed" maxlength="8" value="${item.fixed_er_price}">
											</td>
										</tr>
									</c:forEach>
								</tbody>
							</table>
							<div class="btn-group mt5">
								<div class="right">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_L"/></jsp:include>
								</div>
							</div>
<!-- /통화별 환율결정 -->
						</div>
						<div class="col-8">
<!-- 산출구분표 -->
							<div class="title-wrap">
								<h4>산출구분표</h4>
								<div class="btn-group">
									<div class="right">
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
									</div>
								</div>
							</div>
							<div id="PART_OUTPUT_PRICE" style="margin-top: 5px; height: 648px;"></div>
							<div class="btn-group mt5">
								<div class="left">
									총 <strong class="text-primary" id="total_cnt">0</strong>건
								</div>
								<div class="right">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
								</div>
							</div>
<!-- /산출구분표 -->
						</div>
					</div>
<!-- 부품 판매 가격 결정 수식 -->
					<div class="alert alert-secondary mt10">
						<i class="material-iconserror font-16 v-align-middle"></i>
						<span class="text-primary v-align-middle">부품 판매 가격 결정 수식 : </span>
						<span class="v-align-middle">소비자가 = MAKER(List Price) * 딜러할인율 * 결정환율 / 마진율</span>
					</div>
<!-- /부품 판매 가격 결정 수식 -->
					<div id="examExcelGrid" style="height: 0px; width: 170%; overflow: hidden;"></div>
					<div id="itemExcelGrid" style="height: 0px; width: 330%; overflow: hidden;"></div>
				</div>
		</div>
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
	</div>
<!-- /contents 전체 영역 -->
</div>
</form>
</body>
</html>
