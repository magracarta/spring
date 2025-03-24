<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 고객현황 > 개인정보수집내역변경 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-01-29 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		var auiGrid;
		var collectSourceList = []; // 수집경로
	
		$(document).ready(function() {
			collectSourceList = ${codeMapJsonObj.PERSONAL_COLLECT};
			createAUIGrid();
// 			fnInit();
		});
		
		function enter(fieldObj) {
			var field = ["s_cust_name", "s_hp_no"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}

// 		function fnInit() {
// 			var now = $M.getCurrentDate();
// 			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -3));
			// s_end_dt는 ${inputParam.s_current_dt} 이용
			//goSearch();
// 		}
		
		function goSearch() {
			// 같은 고객이 2개 이상나오면 고객수정쪽의 문제
			if($M.checkRangeByFieldName('s_start_dt', 's_end_dt', true) == false) {				
				return;
			}
			var param = {
					s_start_dt : $M.getValue("s_start_dt"),
					s_end_dt : $M.getValue("s_end_dt"),
					s_cust_no : $M.getValue("s_cust_no"),
					s_new_yn : $M.getValue("s_new_yn"),
					s_cust_name : $M.getValue("s_cust_name"),
					s_hp_no : $M.getValue("s_hp_no"),
					s_extend_target_yn : $M.getValue("s_extend_target_yn"),
					s_sort_key : "a.seq_no",
					s_sort_method : "desc",
					s_masking_yn : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
			}
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page+"/search", $M.toGetParam(param), '',
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						// for (var i = 0; i < result.list.length; ++i) {
						// 	var row = result.list[i];
						// 	var arr = [];
						// 	// 마케팅 동의안했는데, 마케팅 수신방법에 Y 표시한 고객 제외
						// 	if (row.marketing_yn == "Y") {
						// 		if (row.tel_yn == "Y"){arr.push("tel");}
						// 	    if (row.sms_yn == "Y"){arr.push("sms");}
						// 	    if (row.email_yn == "Y"){arr.push("email");}
						// 	    if (row.dm_yn == "Y"){arr.push("dm");}
						// 	}
						//     row['reg_date'] = $M.formatDate(row.reg_date);
						//  	// htmlTemplate에 맞게 가공
						//     row['check'] = arr.join(",");
						// }
						AUIGrid.setGridData(auiGrid, result.list);
					} 
				}
			);
		}
		
		function goSave() {
			// 수정된 행 아이템들(배열)
			var editedRowItems = AUIGrid.getEditedRowItems(auiGrid);
			if (editedRowItems.length == 0) {
				alert("수정된 항목이 없습니다.");
				return false;
			}
			var frm = $M.createForm();
			// 그리드에 명시된 행만 추출함
			var columns = fnGetColumns(auiGrid);
			// 추가는 없기때문에 edittedRow에서만 함.
			for(var i = 0, n = editedRowItems.length; i < n; i++) {
				var row = editedRowItems[i];
				frm = fnToFormData(frm, columns, row);
				// check 컬럼을 yn으로 각각 분리
				// if (row.check.indexOf("tel") != -1){
				// 	$M.setHiddenValue(frm, "tel_yn", "Y");
				// } else {
				// 	$M.setHiddenValue(frm, "tel_yn", "N");
				// }
				// if (row.check.indexOf("email") != -1){
				// 	$M.setHiddenValue(frm, "email_yn", "Y");
				// } else {
				// 	$M.setHiddenValue(frm, "email_yn", "N");
				// }
				// if (row.check.indexOf("sms") != -1){
				// 	$M.setHiddenValue(frm, "sms_yn", "Y");
				// } else {
				// 	$M.setHiddenValue(frm, "sms_yn", "N");
				// }
				// if (row.check.indexOf("dm") != -1){
				// 	$M.setHiddenValue(frm, "dm_yn", "Y");
				// } else {
				// 	$M.setHiddenValue(frm, "dm_yn", "N");
				// }
				var hasCmd = 'cmd' in row;
				if(hasCmd == false) {
					$M.setHiddenValue(frm, 'cmd', 'U');
				}
			}
			$M.goNextPageAjaxSave(this_page, frm, {method : 'POST'}, 
				function(result) {
					if(result.success) {
						AUIGrid.removeSoftRows(auiGrid);
						AUIGrid.resetUpdatedItems(auiGrid);
					}
				}
			);
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				editable : true,
				rowStyleFunction : function(rowIndex, item) {
					if(item.extend_target_yn == "Y") {
						return "aui-privacy_extend_target";
					}
					return "";
				}
			};
			var dropDownListRenderer = {
				type : "DropDownListRenderer",
				list : collectSourceList,
				keyField : "code_value",
				valueField  : "code_name",
				editable : true
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					dataField : "cust_no",
					visible : false
				},
				{ 
					headerText : "변경일", 
					dataField : "reg_date",
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "65",
					minWidth : "65",
					editable : false
				},
				{
					headerText : "구분", 
					dataField : "seq_no",
					width : "35",
					minWidth : "35",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if (value == 1){
							return "신규";
						} else {
							return "변경";
						}
					},
					editable : false
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name",
					width : "90",
					minWidth : "60",
					style : "aui-popup",
					editable : false
				},
				{ 
					headerText : "휴대폰", 
					dataField : "hp_no", 
					width : "100",
					minWidth : "90",
					editable : false
				},
				{ 
					headerText : "담당자", 
					dataField : "reg_id", 
					width : "80",
					minWidth : "40",
					editable : false
				},
				{
					headerText : "최종거래일",
					dataField : "cust_last_deal_dt",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "80",
					minWidth : "80",
					editable : false
				},
				{
					headerText : "동의서파일",
					dataField : "file_yn",
					width : "80",
					minWidth : "60",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (value == 'Y') {
							return "aui-popup";
						} else {
							return null;
						}
					},
					editable : false
				},
				{
					dataField : "file_seq",
					visible : false
				},
				{ 
					headerText : "개인정보수집동의", 
					children: [
						{
							headerText : "동의",
							dataField : "personal_yn",
							width : "35",
							minWidth : "35",
							renderer: {
								type : "CheckBoxEditRenderer",
								showLabel : false,
								editable : true,
								checkValue : "Y",
								unCheckValue : "N",
								// 체크박스 disabled 함수
								disabledFunction: function (rowIndex, columnIndex, value, isChecked, item, dataField) {
									if (item.personal_edit_yn != "Y") {
										return true;
									}
									return false;
								}
							},
						},
						{ 
							headerText : "확인자", 
							dataField : "personal_mem_name", 
							style : "aui-center",
							width : "80",
							minWidth : "60",
							editable : false
						},
						{ 
							headerText : "확인자 ID", 
							dataField : "personal_mem_no", 
							style : "aui-center",
							visible : false,
							editable : false
						},
						{ 
							headerText : "날짜", 
							dataField : "personal_dt", 
							dataType : "date",   
							width : "65",
							minWidth : "65",
							style : "aui-center aui-editable",
							dataInputString : "yyyymmdd",
							formatString : "yy-mm-dd",
							editRenderer : {
								  type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
								  defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
								  onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
								  maxlength : 8,
								  onlyNumeric : true, // 숫자만
								  validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
									  return fnCheckDate(oldValue, newValue, rowItem);
								  }
							},
							editable : true
						},
						{
							headerText : "수집",
							dataField : "personal_collect_cd",
							width : "85",
							minWidth : "85",
							editRenderer : {
								type : "DropDownListRenderer",
								list : collectSourceList,
								keyField : "code_value",
								valueField  : "code_name",
								editable : true,
								conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
									if (item.personal_yn == "Y") {
											return dropDownListRenderer;
									}
								}
							},
							labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
								var retStr = "";
								for(var i=0,len=collectSourceList.length; i<len; i++) {
									if(collectSourceList[i]["code_value"] == value) {
										retStr = collectSourceList[i]["code_name"];
										break;
									}
								}
								return retStr;
							}
						}
					]
				},
				{ 
					headerText : "제3자 정보제공동의", 
					children: [
						{
							headerText : "동의",
							dataField : "three_yn",
							width : "35",
							minWidth : "35",
							renderer: {
								type : "CheckBoxEditRenderer",
								showLabel : false,
								editable : true,
								checkValue : "Y",
								unCheckValue : "N",
								// 체크박스 disabled 함수
								disabledFunction: function (rowIndex, columnIndex, value, isChecked, item, dataField) {
									if (item.three_edit_yn != "Y")
										return true; // true 반환하면 disabled 시킴
									return false;
								}
							}
						},
						{ 
							headerText : "확인자", 
							dataField : "three_mem_name", 
							style : "aui-center",
							width : "80",
							minWidth : "60",
							editable : false
						},
						{ 
							headerText : "확인자 ID", 
							dataField : "three_mem_no", 
							style : "aui-center",
							visible : false,
							editable : false
						},
						{ 
							headerText : "날짜", 
							dataField : "three_dt", 
							dataType : "date",   
							width : "65",
							minWidth : "65",
							style : "aui-center aui-editable",
							dataInputString : "yyyymmdd",
							formatString : "yy-mm-dd",
							editRenderer : {
								  type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
								  defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
								  onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
								  maxlength : 8,
								  onlyNumeric : true, // 숫자만
								  validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
									  return fnCheckDate(oldValue, newValue, rowItem);
								  }
							},
							editable : true
						},
						{
							headerText : "수집",
							dataField : "three_collect_cd",
							width : "85",
							minWidth : "85",
							editRenderer : {
								type : "ConditionRenderer",
								conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
									if (item.three_yn == "Y") {
										return dropDownListRenderer;
									}
								}
							},
							labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
								var retStr = "";
								for(var i=0,len=collectSourceList.length; i<len; i++) {
									if(collectSourceList[i]["code_value"] == value) {
										retStr = collectSourceList[i]["code_name"];
										break;
									}
								}
								return retStr;
							}
						}
					]
				},
				{ 
					headerText : "마케팅활용동의", 
					children: [
						{
							headerText : "동의",
							dataField : "marketing_yn",
							width : "35",
							minWidth : "35",
							renderer: {
								type : "CheckBoxEditRenderer",
								showLabel : false,
								editable : true,
								checkValue : "Y",
								unCheckValue : "N",
								// 체크박스 disabled 함수
								disabledFunction: function (rowIndex, columnIndex, value, isChecked, item, dataField) {
									if (item.marketing_edit_yn != "Y") {
										return true;
									}
									return false;
								}
							}
						},
						{ 
							headerText : "확인자", 
							dataField : "marketing_mem_name", 
							style : "aui-center",
							width : "80",
							minWidth : "60",
							editable : false
						},
						{ 
							headerText : "확인자 id", 
							dataField : "marketing_mem_no", 
							style : "aui-left",
							visible : false,
							editable : false
						},
						{ 
							headerText : "날짜", 
							dataField : "marketing_dt", 
							dataType : "date",   
							width : "65",
							minWidth : "65",
							style : "aui-center aui-editable",
							dataInputString : "yyyymmdd",
							formatString : "yy-mm-dd",
							editRenderer : {
								  type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
								  defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
								  onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
								  maxlength : 8,
								  onlyNumeric : true, // 숫자만
								  validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
									  return fnCheckDate(oldValue, newValue, rowItem);
								  }
							},
							editable : true
						},
						{
							headerText : "수집",
							dataField : "marketing_collect_cd",
							width : "85",
							minWidth : "85",
							editRenderer : {
								type : "ConditionRenderer",
								conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
									if (item.marketing_yn == "Y") {
										return dropDownListRenderer;
									}
								}
							},
							labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
								var retStr = "";
								for(var i=0,len=collectSourceList.length; i<len; i++) {
									if(collectSourceList[i]["code_value"] == value) {
										retStr = collectSourceList[i]["code_name"];
										break;
									}
								}
								return retStr;
							}
						},
						// {
						// 	dataField : "check",
						// 	headerText : "수신방법",
						// 	width : "180",
						// 	minWidth : "180",
						// 	editable : false, // 그리드의 에디팅 사용 안함( 템플릿에서 만든 Select 로 에디팅 처리 하기 위함 )
						// 	renderer : { // HTML 템플릿 렌더러 사용
						// 		type : "TemplateRenderer",
						// 		aliasFunction : function (rowIndex, columnIndex, value, headerText, item ) { // 엑셀, PDF 등 내보내기 시 값 가공 함수
						// 			return value.replace('tel', "전화").replace('sms', "SMS").replace('email', "메일").replace('dm', "우편").replace(/,/g, "/");
					    //         }
						// 	},
						// 	// dataField 로 정의된 필드 값이 HTML 이라면 labelFunction 으로 처리할 필요 없음.
						// 	labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { // HTML 템플릿 작성
						// 		var valueArr = value == "" ? "" : value.split(",");
						// 		var inputTagArr = [];
						// 		var template = '<div>';
						// 		if (item.marketing_yn == "Y" && item.marketing_edit_yn == "Y" ) {
						// 			template += '<span>';
						// 			inputTagArr[0] = '<input type="checkbox" value="tel" onclick="javascript:fnClickCheck(' + rowIndex + ', event);">전화';
						// 			inputTagArr[1] = '<input type="checkbox" value="sms" onclick="javascript:fnClickCheck(' + rowIndex + ', event);">SMS';
						// 			inputTagArr[2] = '<input type="checkbox" value="email" onclick="javascript:fnClickCheck(' + rowIndex + ', event);">메일';
						// 			inputTagArr[3] = '<input type="checkbox" value="dm" onclick="javascript:fnClickCheck(' + rowIndex + ', event);">우편';
						// 			for(var i=0, len=valueArr.length; i<len; i++) {
						// 				switch(valueArr[i]) {
						// 				case "tel":
						// 					inputTagArr[0] = '<input type="checkbox" checked="checked" value="tel" onclick="javascript:fnClickCheck(' + rowIndex + ', event);">전화';
						// 					break;
						// 				case "sms":
						// 					inputTagArr[1] = '<input type="checkbox" checked="checked" value="sms" onclick="javascript:fnClickCheck(' + rowIndex + ', event);">SMS';
						// 					break;
						// 				case "email":
						// 					inputTagArr[2] = '<input type="checkbox" checked="checked" value="email" onclick="javascript:fnClickCheck(' + rowIndex + ', event);">메일';
						// 					break;
						// 				case "dm":
						// 					inputTagArr[3] = '<input type="checkbox" checked="checked" value="dm" onclick="javascript:fnClickCheck(' + rowIndex + ', event);">우편';
						// 					break;
						// 				}
						// 			}
						// 			template += inputTagArr.join('');
						// 			template += '</span>';
						// 		}
						// 		template += '</div>';
						// 		return template;
						// 	}
						// }
					]
				},
				{
					headerText : "고객발송",
					dataField : "sendBtn",
					width : "80",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var param = {
								"modusign_id" : event.item["modusign_id"],
								"email": event.item["email"],
								"hp_no": $M.getValue("s_masking_yn") == "Y"? "" : event.item["hp_no"],
							};
							openSendModuDocumentPanel($M.toGetParam(param));
						},
						visibleFunction : function(rowIndex, columnIndex, value, item, dataField ) {
							if(item.send_yn == 'Y') {
								return true;
							}
							else {
								return false;
							}
						}
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return '발송'
					},
					style : "aui-center",
					editable : true
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				
			});
			AUIGrid.bind(auiGrid, "cellEditBegin", function(event) {
				if(event.dataField == "personal_dt" || event.dataField == "personal_collect_cd") {
					// 추가된 행 아이템인지 조사하여 추가된 행인 경우만 에디팅 진입 허용
					if (event.item.personal_edit_yn != "Y"){
						setTimeout(function() {
							AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "APP에서 수집되어 수정할 수 없습니다.");
						}, 1);
						return false;
					} else {
						if (event.item.personal_yn == "Y") {
							return true;
						} else {
							setTimeout(function () {
								AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "개인정보수집에 동의하지 않으면 수정할 수 없습니다.");
							}, 1);
							return false; // false 반환하면 기본 행위 안함(즉, cellEditBegin 의 기본행위는 에디팅 진입임)
						}
					}
				}
				if(event.dataField == "three_dt" || event.dataField == "three_collect_cd") {
					// 추가된 행 아이템인지 조사하여 추가된 행인 경우만 에디팅 진입 허용
					if (event.item.three_edit_yn != "Y"){
						setTimeout(function() {
							AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "APP에서 수집되어 수정할 수 없습니다.");
						}, 1);
						return false;
					} else {
						if (event.item.three_yn == "Y") {
							return true;
						} else {
							setTimeout(function () {
								AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "제3자 정보제공에 동의하지 않으면 수정할 수 없습니다.");
							}, 1);
							return false; // false 반환하면 기본 행위 안함(즉, cellEditBegin 의 기본행위는 에디팅 진입임)
						}
					}
				}
				if(event.dataField == "marketing_dt" || event.dataField == "marketing_collect_cd") {
					// 추가된 행 아이템인지 조사하여 추가된 행인 경우만 에디팅 진입 허용
					if (event.item.marketing_edit_yn != "Y"){
						setTimeout(function() {
							AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "고객확인 중에 수정할 수 없습니다.");
						}, 1);
						return false;
					} else {
						if (event.item.marketing_yn == "Y") {
							return true;
						} else {
							setTimeout(function () {
								AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "마케팅활용에 동의하지 않으면 수정할 수 없습니다.");
							}, 1);
							return false; // false 반환하면 기본 행위 안함(즉, cellEditBegin 의 기본행위는 에디팅 진입임)
						}
					}
				}
				return true; // 다른 필드들은 편집 허용
			});
			AUIGrid.bind(auiGrid, "cellEditEnd", function(event) {
				// 체크 박스에 맞는 rowItem 얻기
				var rowItem = AUIGrid.getItemByRowIndex(auiGrid, event.rowIndex);
				if (event.dataField == "personal_yn") {
					if (event.value == "Y") {
						rowItem.personal_dt = $M.getCurrentDate();
						rowItem.personal_mem_name = "${SecureUser.user_name }";
						rowItem.personal_mem_no = "${SecureUser.mem_no }";
						rowItem.personal_collect_cd = "1";
					} else {
						rowItem.personal_dt = "";
						rowItem.personal_mem_name = "";
						rowItem.personal_mem_no = "";
						rowItem.personal_collect_cd = "";
						
					}
				}
				if (event.dataField == "three_yn") {
					if (event.value == "Y") {
						rowItem.three_dt = $M.getCurrentDate();
						rowItem.three_mem_name = "${SecureUser.user_name }";
						rowItem.three_mem_no = "${SecureUser.mem_no }";
						rowItem.three_collect_cd = "1";
					} else {
						rowItem.three_dt = "";
						rowItem.three_mem_name = "";
						rowItem.three_mem_no = "";
						rowItem.three_collect_cd = "";
					}
				}
				if (event.dataField == "marketing_yn") {
					if (event.value == "Y") {
						rowItem.marketing_dt = $M.getCurrentDate();
						rowItem.marketing_mem_name = "${SecureUser.user_name }";
						rowItem.marketing_mem_no = "${SecureUser.mem_no }";
						rowItem.marketing_collect_cd = "1";
						rowItem.check = "";
					} else {
						rowItem.marketing_dt = "";
						rowItem.marketing_mem_name = "";
						rowItem.marketing_mem_no = "";
						rowItem.marketing_collect_cd = "";
						rowItem.check = "";
					}
				}
				if (event.dataField == "personal_dt" || event.dataField == "personal_collect_cd") {
					if (rowItem.personal_yn == "Y") {
						rowItem.personal_mem_name = "${SecureUser.user_name }";
						rowItem.personal_mem_no = "${SecureUser.mem_no }";
					}
				}
				if (event.dataField == "three_dt" || event.dataField == "three_collect_cd") {
					if (rowItem.three_yn == "Y") {
						rowItem.three_mem_name = "${SecureUser.user_name }";
						rowItem.three_mem_no = "${SecureUser.mem_no }";
					}
				}
				if (event.dataField == "marketing_dt" || event.dataField == "marketing_collect_cd") {
					if (rowItem.marketing_yn == "Y") {
						rowItem.marketing_mem_name = "${SecureUser.user_name }";
						rowItem.marketing_mem_no = "${SecureUser.mem_no }";
					}
				}
				// row 데이터 업데이트
				AUIGrid.updateRow(auiGrid, rowItem, event.rowIndex);
			});
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "cust_name") {
					var param = {
						cust_no : 	event.item.cust_no
					}
					var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1280, height=800, left=0, top=0";
					$M.goNextPage('/cust/cust0104p01', $M.toGetParam(param), {popupStatus : poppupOption});
				}
				if(event.dataField == "file_yn") {
					if (event.item.file_yn == "Y") {
						openFileViewerPanel(event.item.file_seq);
					}
				}
			});
			AUIGrid.setGridData(auiGrid, []);
		}
		
		// 체크박스 클릭
		function fnClickCheck(rowIndex, event) {
			var target = event.target ? event.target : event.srcElement;
			// 해당 행의 아이템 얻기
			var item = AUIGrid.getItemByRowIndex(auiGrid, rowIndex);
			var checkValue = item.check;
			var checkArr = checkValue.split(",");
			 // 체크된 경우 포함시킴
			if(target.checked) {
				checkArr.push(target.value);
			} else {
				// 해제된 경우 제거함.
				checkArr.splice(checkArr.indexOf(target.value),1);
			}
			// 배열에서 빈값 삭제
			checkArr = checkArr.filter(function(e){return e}); 
			// 그리드 값 수정함.
			AUIGrid.updateRow(auiGrid, {"check" : checkArr.join(",")}, rowIndex);
		}
		
		// 엑셀다운로드
		function fnDownloadExcel() {
			var exportProps = {
				// 제외항목
			    exceptColumnFields : ["personal_mem_id", "three_mem_id", "marketing_mem_id"]
			};
			fnExportExcel(auiGrid, "개인정보수집내역변경", exportProps);
		}
		
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
<!-- /메인 타이틀 -->
				<div class="contents">
<!-- 기본 -->					
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="60px">
								<col width="260px">
								<col width="40px">
								<col width="100px">
								<col width="60px">
								<col width="110px">
								<col width="60px">
								<col width="70px">
								<col width="150px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>변경일</th>
									<td>
										<div class="form-row inline-pd ">
			                                 <div class="col-5">
			                                    <div class="input-group">
			                                       <input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="시작일" value="${searchDtMap.s_start_dt}" >
			                                    </div>
			                                 </div>
			                                 <div class="col-auto">~</div>
			                                 <div class="col-5">
			                                    <div class="input-group">
			                                       <input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="종료일" value="${searchDtMap.s_end_dt}">
			                                    </div>
			                                 </div>
			                                 <jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
				                     		<jsp:param name="st_field_name" value="s_start_dt"/>
				                     		<jsp:param name="ed_field_name" value="s_end_dt"/>
				                     		<jsp:param name="click_exec_yn" value="Y"/>
				                     		<jsp:param name="exec_func_name" value="goSearch();"/>
				                     		</jsp:include>	
			                              </div>
									</td>									
									<th>고객명</th>
									<td>
				                     	<input type="text" class="form-control" id="s_cust_name" name="s_cust_name">
									</td>
									<th>휴대폰</th>
									<td>
				                     	<input type="text" class="form-control" id="s_hp_no" name="s_hp_no">
									</td>
									<th>구분</th>
									<td>
										<select class="form-control" id="s_new_yn" name="s_new_yn">
											<option value="">- 전체 -</option>
											<option value="Y">신규</option>
											<option value="N">변경</option>
										</select>
									</td>
									<th>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="s_extend_target_yn" name="s_extend_target_yn" value="Y">
											<label class="form-check-label mr5" for="s_extend_target_yn">연장동의대상자</label>
										</div>
									</th>
									<td class="">
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>
								</tr>								
							</tbody>
						</table>
					</div>
<!-- /기본 -->	
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>변경내역</h4>
						<div class="btn-group">
							<div class="right">
								<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
								<div class="form-check form-check-inline">
									<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
									<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
								</div>
								</c:if>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->					

					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>						
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>		
		</div>
<!-- /contents 전체 영역 -->
</form>	
</body>
</html>