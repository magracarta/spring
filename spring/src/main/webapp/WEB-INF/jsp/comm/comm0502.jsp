<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 결재선관리 > 결재업무관리 > null > null
-- 작성자 : 박예진
-- 최초 작성일 : 2019-01-13 15:01:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGridLeft;
		var auiGridCenter;
		var auiGridRight;
		var auiGridCover;
		var rowIndex;
		// 결재단계
		var apprLevel;
		var paramsLeft;
		var dropDownList = ["Y", "N"];

		// 결재대행 적용
		function goApply() {
			var list = AUIGrid.getGridData(auiGridCover);
			if (list.length == 0) {
				alert("적용할 내용이 없습니다.");
				return false;
			}
			if (isValid() == false) {
				return false;
			}
			for (var i = 0; i < list.length; ++i) {
				if (list[i].cover_st_dt > list[i].cover_ed_dt) {
					alert(i+1+"행의 기간을 다시 설정하세요.");
					return false;
				}
				if (list[i].appr_mem_no == list[i].instead_mem_no) {
					alert(i+1+"행의 결재자를 다시 설정하세요.");
					return false;
				}
			}
			if (confirm("결재대행를 적용하시겠습니까?") == false) {
				return false;
			}
			var frm = fnChangeGridDataToForm(auiGridCover);
			$M.goNextPageAjax(this_page + "/cover", frm, {method : 'POST'},
					function(result) {
						if(result.success) {
							AUIGrid.removeSoftRows(auiGridCover);
							AUIGrid.resetUpdatedItems(auiGridCover);
						};
					}
			);
		}


		// 결재대행 행추가
		function fnAdd() {
			if ($M.getValue("appr_job_cd") == "") {
				alert("결재타입을 선택하세요");
				return false;
			}
			var obj = new Object();
			obj.appr_job_cd = $M.getValue("appr_job_cd");
			obj.appr_mem_no = "";
			obj.instead_mem_no = "";
			obj.appr_mem_name = "";
			obj.instead_mem_name = "";
			obj.cover_st_dt = "";
			obj.cover_ed_dt = "";
			AUIGrid.addRow(auiGridCover, obj);
		}

		// 결재대행
		function createAUIGridCover() {
			var gridPros = {
				// rowIdField 설정
				rowIdField: "_$uid",
				// rowIdField가 unique 임을 보장
				rowIdTrustMode: true,
				// rowNumber 
				showRowNumColumn: true,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				fillColumnSizeMode : false,
				height : "100",
				editable : true
			};
			var columnLayout = [
				{
					dataField : "appr_job_cd",
					visible : false
				},
				{
					dataField : "appr_mem_no",
					visible : false
				},
				{
					dataField : "instead_mem_no",
					visible : false
				},
				{
					headerText : "결재자",
					dataField : "appr_mem_name",
					width : "100",
					minWidth : "100",
					style : "aui-center aui-popup",
					editable : false,
				},
				{
					headerText : "결재대행자",
					dataField : "instead_mem_name",
					width : "100",
					minWidth : "100",
					style : "aui-center aui-popup",
					editable : false
				},
				{
					headerText : "시작일",
					dataField : "cover_st_dt",
					dataType : "date",
					width : "120",
					minWidth : "120",
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
						},
						showEditorBtnOver : true
					},
					editable : true
				},
				{
					headerText : "종료일",
					dataField : "cover_ed_dt",
					dataType : "date",
					width : "120",
					minWidth : "120",
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
						},
						showEditorBtnOver : true
					},
					editable : true
				},
				{
					headerText : "삭제",
					dataField : "btnDel",
					width : "120",
					minWidth : "80",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGridCover, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);
							} else {
								AUIGrid.restoreSoftRows(auiGridCover, "selectedIndex");
							}
						},
					},
					labelFunction : function(rowIndex, columnIndex, value,
											 headerText, item) {
						return '삭제'
					},
					editable : false
				},
			];
			// 실제로 #grid_wrap 에 그리드 생성
			auiGridCover = AUIGrid.create("#auiGrid_cover", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridCover, []);

			AUIGrid.bind(auiGridCover, "cellClick", function(event) {
				var frm = document.main_form;
				rowIndex = event.rowIndex;
				// 결재 지정자 클릭 시
				if(event.dataField == "appr_mem_name") {
					var param = {
					};
					openSearchMemberPanel('fnSetMemInfo', $M.toGetParam(param));
					// 결재 대상자 클릭 시
				} else if (event.dataField == "instead_mem_name") {
					if(event.item["mem_name"] == "") {
						alert("결재 지정자를 먼저 지정해주세요.");
						return false;
					}
					var param = {
					};
					openSearchMemberPanel('fnSetCoverMemInfo', $M.toGetParam(param));
				}
			});
		}

		// 결재 대상자 팝업 데이터 세팅
		function fnSetMemInfo(data) {
			var isValid = AUIGrid.isUniqueValue(auiGridCover, "appr_mem_no", data.mem_no);
			if (isValid == false) {
				AUIGrid.showToastMessage(auiGridCover, rowIndex, 3, "이미 등록된 결재자입니다.");
				return false;
			}
			AUIGrid.updateRow(auiGridCover, { "appr_mem_no" : data.mem_no }, rowIndex);
			AUIGrid.updateRow(auiGridCover, { "appr_mem_name" : data.mem_name }, rowIndex);
		}

		// 결재 지정자 팝업 데이터 세팅
		function fnSetCoverMemInfo(data) {
			AUIGrid.updateRow(auiGridCover, { "instead_mem_no" : data.mem_no }, rowIndex);
			AUIGrid.updateRow(auiGridCover, { "instead_mem_name" : data.mem_name }, rowIndex);
		}

		// 결재대행 그리드 빈값 체크
		function isValid() {
			return AUIGrid.validateGridData(auiGridCover, ["appr_mem_name", "instead_mem_name", "cover_st_dt", "cover_ed_dt"], "필수 항목는 반드시 값을 입력해야 합니다.");
		}

		// 결재라인 초기화
		function goReset() {
			var apprJobCd = $M.getValue("appr_job_cd");
			if (apprJobCd == "") {
				alert("결재타입을 선택하세요.");
				return false;
			}
			//var msg = $M.getValue("appr_job_name")+"("+$M.getValue("org_code")+") 결재라인을 초기화하시겠습니까?";
			var msg = "기존에 사용했던 결재라인이 초기화됩니다.\n"+$M.getValue("appr_job_name")+" 결재라인을 초기화하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, this_page + "/reuse/" + apprJobCd, "", { method : 'post'},
					function(result) {
						if(result.success) {

						}
					}
			);
		}

		function fnChangeApprLineFix() {
			var fix = $M.getValue("appr_line_fix_yn");
			if (fix == "Y") {
				$("#fixAppr").show();
				$("#noFixAppr").hide();
			} else {
				$("#fixAppr").hide();
				$("#noFixAppr").show();
			}
			$("#auiGridCenter").resize();
			$("#auiGridRight").resize();
		}

		function fnRemoveFix1() {
			var param = {
				fix_1_mem_no : "",
				fix_1_mem_name : ""
			}
			$M.setValue(param);
		}

		function fnRemoveFix2() {
			var param = {
				fix_2_mem_no : "",
				fix_2_mem_name : ""
			}
			$M.setValue(param);
		}

		function fnRemoveFix3() {
			var param = {
				fix_3_mem_no : "",
				fix_3_mem_name : ""
			}
			$M.setValue(param);
		}

		// 고정 결재1
		function setMemFix1(row) {
			var param = {
				fix_1_mem_no : row.mem_no,
				fix_1_mem_name : row.mem_name
			}
			$M.setValue(param);
		}

		// 고정 결재2
		function setMemFix2(row) {
			var param = {
				fix_2_mem_no : row.mem_no,
				fix_2_mem_name : row.mem_name
			}
			$M.setValue(param);
		}

		// 고정 결재3
		function setMemFix3(row) {
			var param = {
				fix_3_mem_no : row.mem_no,
				fix_3_mem_name : row.mem_name
			}
			$M.setValue(param);
		}

		function fnSetMemNo(row) {
			var param = {
				last_appr_mem_no : row.mem_no,
				last_appr_mem_name : row.mem_name
			}
			$M.setValue(param);
		}

		$(document).ready(function() {
			// 결재업무 목록 그리드
			createAUIGridLeft();
			// 직책 목록 그리드
			createAUIGridCenter();
			// 결재선 목록 그리드
			createAUIGridRight();
			// 초기값 세팅
			fnInitSetting();
			// 결재대행 목록 그리드
			createAUIGridCover();
		});

		// 초기값 세팅
		function fnInitSetting() {
			var frm = document.main_form;
			var param = {
				writer_appr_yn : "N",
				line_modify_yn : "N",
			}
			$M.setValue(param);

			fnChangeAutoAppr();
		}

		//조회
		function goSearch(init) {
			var param = {
				"s_appr_job_cd" : $M.getValue("s_appr_job_cd"),
				"s_use_yn" : $M.getValue("s_use_yn")
			};
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							AUIGrid.setGridData(auiGridLeft, result.list);
							$("#total_cnt").html(result.total_cnt);
							if (init != undefined) {
								fnNew();
								AUIGrid.clearGridData(auiGridCenter);
								AUIGrid.clearGridData(auiGridRight);
								AUIGrid.clearGridData(auiGridCover);
								$M.setValue("s_web_id","");
								$M.setValue("use_yn","Y");
								$M.setValue("self_appr_yn", "N");
								$M.setValue("appr_line_fix_yn", "");
								$M.setValue("comm_yn", "");
								$M.setValue("org_code", "");
								$M.setValue("org_name", "");
								$M.setValue("last_appr_mem_no","");
								$M.setValue("last_appr_mem_name","");
								$M.setValue("auto_appr_yn","N");
								$M.setValue("auto_appr_cnt","");
							}
						};
					}
			);
		}

		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = [ "s_appr_job_name", "s_use_yn" ];
			$.each(field, function() {
				if (fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}

		// 신규
		function fnNew() {
			var frm = document.main_form;
			apprLevel = 0;
			$M.setValue(frm, "cmd", "C");
			$M.setValue(frm, "codeGrid", "C");
			var param = {
				appr_job_name : "",
				appr_job_cd : "",
				use_yn : "Y",
				last_appr_mem_no : "",
				last_appr_mem_name : "",
				appr_job_cd : "",
				appr_line_fix_yn : "N",
				fix_1_mem_no : "",
				fix_1_mem_name : "",
				fix_1_writer_appr_yn : "",
				fix_2_mem_no : "",
				fix_2_mem_name : "",
				fix_2_writer_appr_yn : "",
				fix_3_mem_no : "",
				fix_3_mem_name : "",
			}
			$M.setValue(param);

			AUIGrid.clearSelection(auiGridLeft);
			AUIGrid.clearGridData(auiGridCenter);
			AUIGrid.clearGridData(auiGridRight);

			$M.goNextPageAjax(this_page + "/gradeSearch", "", {method : 'GET'},
					function(result) {
						if(result.success) {
							// 신규 버튼 클릭 시 직책 목록
							AUIGrid.setGridData(auiGridCenter, result.list);
						}
					}
			);

			fnInitSetting();
		}

		// 저장
		function goSave() {
			var frm = document.main_form;
			if($M.validation(frm) == false) {
				return;
			};
			if($M.validation(document.main_form, {field:['appr_job_name']}) == false) {
				return;
			};
			if($M.getValue("auto_appr_yn") == "Y" && $M.getValue("auto_appr_cnt") == "") {
				alert("자동결재가 적용될 인원수를 입력해주세요.");
				return;
			}

			if ($M.getValue("appr_line_fix_yn") == "N") {
				ApprValidation(frm);
			} else {

				if ($M.getValue("fix_1_mem_no") == "") {
					alert("고정결재 첫번째 라인을 입력하세요.");
					$("#fix_1_mem_name").focus();
					return false;
				}

				if (confirm("저장하시겠습니까?") == false) {
					return false;
				}

				var memArr = [$M.getValue("fix_1_mem_no"), $M.getValue("fix_2_mem_no"), $M.getValue("fix_3_mem_no")];
				var ynArr = [$M.getValue("fix_1_writer_appr_yn"), $M.getValue("fix_2_writer_appr_yn"), $M.getValue("fix_3_writer_appr_yn")];
				for (var i = memArr.length-1; i >= 0; i--) {
					if (memArr[i] == "") {
						ynArr.splice(i, 1);
					} else {
						if (ynArr[i] == "") {
							ynArr[i] = "N";
						} else {
							ynArr[i] = "Y";
						}
					}
				}
				var seqArr = [];
				for (var i = 0; i < memArr.length; ++i) {
					seqArr.push(i+1);
				}
				var param = {
					"appr_job_cd" : $M.getValue("appr_job_cd"),
					"seq_no_str" : $M.getArrStr(seqArr),
					"mem_no_str" : $M.getArrStr(memArr),
					"self_appr_yn" : $M.getValue("self_appr_yn") == "" ? "N" : "Y",
					"writer_appr_yn_str" : $M.getArrStr(ynArr),
					"appr_line_fix_yn" : "Y",
					"line_modify_yn" : $M.getValue("line_modify_yn"),
					"comm_yn" : $M.getValue("comm_yn") == "" ? "N" : "Y",
					"org_code" : $M.getValue("org_code"),
					"auto_appr_yn" : $M.getValue("auto_appr_yn") != "Y" ? "N" : "Y",
					"auto_appr_cnt" : $M.getValue("auto_appr_cnt") == "" ? 0 : $M.getValue("auto_appr_cnt"),
					"appr_org_code_str" : $M.getValue("appr_org_code_str"),
					"appr_grade_str" : $M.getValue("appr_grade_str"),
					"appr_mem_str" : $M.getValue("appr_mem_str"),
				};
				$M.goNextPageAjax(this_page+"/fix", $M.toGetParam(param), {method : 'POST'},
						function(result) {
							if(result.success) {
								goSearch();
							}
						}
				);
			}
		}

		function groupBy(objectArray, property) {
			return objectArray.reduce(function (acc, obj) {
				let key = obj[property]
				if (!acc[key]) {
					acc[key] = []
				}
				acc[key].push(obj)
				return acc
			}, {})
		}

		function ApprValidation(frm) {
			// 구분자 ^ join
			var params = AUIGrid.getGridData(auiGridRight);
			var pivotMap = groupBy(params, 'seq_no');
			var tempArr = [];
			var tempKey = [];
			for (var m in pivotMap){
				tempKey.push(m);
				for (var i = 0; i < pivotMap[m].length; i++){
					if (pivotMap[m].length > 1){
						var tempInnerArr = [];
						for (var j = 0; j < pivotMap[m].length; ++j){
							tempInnerArr.push(pivotMap[m][j].code);
						}
						var kkeockse = tempInnerArr.join("^");
						tempArr.push(kkeockse);
						break;
					} else {
						tempArr.push(pivotMap[m][i].code);
					}
				}
			}
			// 기존 결재업무 데이터
			var paramsLeft = apprLineNameJson;
			var paramsNewLeft = AUIGrid.getGridData(auiGridLeft);

			// 결재단계 체크
			if(tempKey.length == 0) {
				alert("첫번째 결재직책 선택은 필수입니다.");
				return;
			}
			for (var i = 0; i < tempKey.length; i++) {
				if(tempKey[i] != i+1) {
					alert("결재단계를 다시 설정해주세요.");
					return;
				}
			}
			var tempSortNo = [];
			for(var i = 0; i < params.length; i++) {
				tempSortNo.push(params[i].sort_no);
			}
			// 결재직책 체크
			/* for (var i = 0; i < params.length; i++) {
				for(var j = i + 1; j < params.length; j++) {
					if(params[i].sort_no > tempSortNo[j]) {
						alert("결재직책 순번이 올바르지 않습니다. \n직책을 다시 설정해주세요.");
						return false;
					}
				}
			} */
			var result = confirm("저장하시겠습니까?");
			if (result) {
				goSaveAppr(tempKey, tempArr);
			}
		}

		function goSaveAppr(tempKey, tempArr) {
			var tempWriter = AUIGrid.getGridData(auiGridRight);
			var pivotMap = groupBy(tempWriter, 'seq_no');
			console.log(pivotMap);
			var tempWirterArr = [];

			// 결재순서(숫자)
			var tempMemNoSortNo = [];
			for (var m in pivotMap){
				for (var i = 0; i < pivotMap[m].length; i++) {
					if (pivotMap[m][i].writer_appr_yn  == undefined || pivotMap[m][i].writer_appr_yn == "") {
						tempWirterArr.push("N");
					} else {
						tempWirterArr.push(pivotMap[m][i].writer_appr_yn);
					}
					if (pivotMap[m][i].mem_no_sort_no == undefined || pivotMap[m][i].mem_no_sort_no == "") {
						tempMemNoSortNo.push(1);
					} else {
						tempMemNoSortNo.push(pivotMap[m][i].mem_no_sort_no);
					}
					break;
				}
			}
			// 결재순서(숫자)
			/* var tempMemNoSortNo = [];
			for (var i = 0; i < tempWriter.length; ++i) {
				if (tempWriter[i] != null) {
					tempMemNoSortNo.push(tempWriter[i].mem_no_sort_no);
				}
			} */

			var param = {
				"appr_job_cd" : $M.getValue("appr_job_cd"),
				"seq_no_str" : $M.getArrStr(tempKey),
				"grade_cd_str_str" : $M.getArrStr(tempArr),
				"appr_job_name" : $M.getValue("appr_job_name"),
				"self_appr_yn" : $M.getValue("self_appr_yn") == "" ? "N" : "Y",
				"line_modify_yn" : $M.getValue("line_modify_yn"),
				"writer_appr_yn_str" : $M.getArrStr(tempWirterArr),
				"appr_line_fix_yn" : $M.getValue("appr_line_fix_yn"),
				"use_yn" : $M.getValue("use_yn"),
				"mem_no_sort_no_str" : $M.getArrStr(tempMemNoSortNo), // 결재순서
				"last_appr_mem_no" : $M.getValue("last_appr_mem_name") == "" ? "" : $M.getValue("last_appr_mem_no"),
				"comm_yn" : $M.getValue("comm_yn") == "" ? "N" : "Y",
				"org_code" : $M.getValue("org_code"),
				"auto_appr_yn" : $M.getValue("auto_appr_yn") != "Y" ? "N" : "Y",
				"auto_appr_cnt" : $M.getValue("auto_appr_cnt") == "" ? 0 : $M.getValue("auto_appr_cnt"),
				"appr_org_code_str" : $M.getValue("appr_org_code_str"),
				"appr_grade_str" : $M.getValue("appr_grade_str"),
				"appr_mem_str" : $M.getValue("appr_mem_str"),
			};
			$M.goNextPageAjax(this_page, $M.toGetParam(param), {method : 'POST'},
					function(result) {
						if(result.success) {
							goSearch();
						}
					}
			);
		}

		// 결재업무 목록 그리드 생성
		function createAUIGridLeft() {
			var gridPros = {
				// rowIdField 설정
				rowIdField: "_$uid",
				// rowIdField가 unique 임을 보장
				rowIdTrustMode: true,
				// rowNumber
				showRowNumColumn: true,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				fillColumnSizeMode : false,
				height : "500",
				headerHeight : 50
			};
			var columnLayout = [
				{
					dataField : "org_code",
					visible : false
				},
				{
					dataField : "appr_job_cd",
					visible : false
				},
				{
					headerText : "결재업무",
					dataField : "appr_job_name",
					width : "120",
					minWidth : "80",
					style : "aui-left",
					editable : false
				},
				{
					headerText : "부서",
					dataField : "org_name",
					width : "75",
					minWidth : "50",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var ret = value;
						if (item.org_code == "0000") {
							ret = "공용";
						}
						return ret;
					},
				},
				{
					headerText : "결재단계",
					dataField : "appr_level",
					style : "aui-left aui-link",
					editable : false
				}/* ,
				{
					headerText : "고정여부",
					dataField : "appr_line_fix_yn",
					width : "55",
					minWidth : "50",
					style : "aui-center",
					editable : false
				} */
			];
			// 실제로 #grid_wrap 에 그리드 생성
			auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridLeft, []);

			AUIGrid.bind(auiGridLeft, "cellClick", function(event) {
				if(event.dataField == "appr_level") {
					var frm = document.main_form;
					$M.setValue(frm, "cmd", "U");
					$M.setValue(frm,'appr_job_cd', event.item['appr_job_cd']);
					var param = {
						"appr_job_cd" : event.item["appr_job_cd"],
						"org_code" : event.item["org_code"]
					};
					goSearchDetail(param);
				}
			});
		}

		// 결재업무 목록 셀 클릭시
		// 상세
		function goSearchDetail(param) {
			var frm = document.main_form;
			$M.setValue(frm, "codeGrid", "U");
			//param값 없으면 return
			if(param == null) {
				return;
			}
			AUIGrid.clearGridData(auiGridCenter);
			AUIGrid.clearGridData(auiGridRight);
			AUIGrid.clearGridData(auiGridCover);
			$M.setValue("s_web_id","");
			$M.setValue("use_yn","Y");
			$M.setValue("last_appr_mem_no","");
			$M.setValue("last_appr_mem_name","");
			$M.goNextPageAjax(this_page + "/detail", $M.toGetParam(param), { method : 'get'},
					function(result) {
						if(result.success) {
							//fnNew();
							var row = result.apprType;
							apprModifyList = result.apprLineList;
							if (row == undefined) {
								alert("결재타입이 올바르지 않습니다. 관리자에게 문의하세요! [t_code.code_v1값 이 있는지 확인, 최초 Y로 넣을것]");
								return false;
							}
							$M.setValue("appr_job_cd", row.appr_job_cd);
							$M.setValue("appr_job_name", row.appr_job_name);

							$M.setValue("self_appr_yn", row.self_appr_yn);
							$M.setValue("writer_appr_yn", row.writer_appr_yn);
							$M.setValue("org_code", row.org_code);
							if (row.org_code == "0000") {
								$M.setValue("org_name", "공용");
							} else {
								$M.setValue("org_name", row.org_name);
							}
							$M.setValue("comm_yn", row.comm_yn);

							$M.setValue("auto_appr_yn", row.auto_appr_yn);
							$M.setValue("auto_appr_cnt", row.auto_appr_cnt);
							if($M.nvl(row.appr_org_code_str, "") != "") {
								$M.setValue('appr_org_code_str', row.appr_org_code_str.split("#"));
							}
							if($M.nvl(row.appr_grade_str, "") != "") {
								$M.setValue('appr_grade_str', row.appr_grade_str.split("#"));
							}
							if($M.nvl(row.appr_mem_str, "") != "") {
								$M.setValue('appr_mem_str', row.appr_mem_str.split("#"));
							}

							$M.clearValue({field:["last_appr_mem_no", "last_appr_mem_name"]});
							if($M.nvl(row.last_appr_mem_no, "") != "") {
								$M.setValue("last_appr_mem_no", row.last_appr_mem_no);
								$M.setValue("last_appr_mem_name", $M.nvl(row.last_appr_mem_name, ""));
							} else {
								$M.setValue("last_appr_mem_no", "");
								$M.setValue("last_appr_mem_name", "");
							}
							$M.setValue("appr_line_fix_yn", row.appr_line_fix_yn);
							fnInitSetting();
							//#
							AUIGrid.setGridData(auiGridCenter, result.gradeList);
							AUIGrid.setGridData(auiGridRight, result.apprLineList);
							AUIGrid.setGridData(auiGridCover, result.apprCoverList);

							// 초기화
							for (var i = 0; i < 3; ++i) {
								$M.setValue("fix_"+(i+1)+"_writer_appr_yn", "");
								$M.setValue("fix_"+(i+1)+"_mem_no", "");
								$M.setValue("fix_"+(i+1)+"_mem_name", "");
							}

							if (result.apprTypeFix) {
								for (var i = 0; i < result.apprTypeFix.length; ++i) {
									$M.setValue("fix_"+(i+1)+"_mem_no", result.apprTypeFix[i].mem_no);
									$M.setValue("fix_"+(i+1)+"_mem_name", result.apprTypeFix[i].mem_name);
									if (result.apprTypeFix[i].writer_appr_yn == "Y") {
										$("#fix_"+(i+1)+"_writer_appr_yn").prop('checked', true);
									} else {
										$("#fix_"+(i+1)+"_writer_appr_yn").prop('checked', false);
									}
								}
							}

							AUIGrid.setAllCheckedRows(auiGridCenter,false);
							AUIGrid.setAllCheckedRows(auiGridRight,false);
							fnChangeApprLineFix();

							$M.setValue("line_modify_yn", row.line_modify_yn);

							// 복사를 위해
							// 부서별 업무
							var jobSelObj = $M.getComp('copy_appr_job_cd');
							jobSelObj.options.length = 0;
							if(result.apprJobList.length > 0) {
								$.each(result.apprJobList, function() {
									jobSelObj.add(new Option(this.code_name, this.code_value));
								});
							}

							// 부서목록
							var orgSelObj = $M.getComp('copy_org_code');
							orgSelObj.options.length = 0;
							orgSelObj.add(new Option("- 전체 -", ""));
							if(result.apprOrgList.length > 0) {
								$.each(result.apprOrgList, function() {
									orgSelObj.add(new Option(this.org_name, this.org_code));
								});
							}
						}
					}
			);
		}

		// 직책목록 그리드
		function createAUIGridCenter() {
			var gridPros = {
				// rowIdField 설정
				rowIdField: "sort_no",
				// rowNumber
				showRowNumColumn: true,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				//체크박스 출력 여부
				showRowCheckColumn : true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				enableFilter : true,
				// 행 소프트 제거 모드 해제
				softRemoveRowMode : false,
				fillColumnSizeMode : false,
				rowIdTrustMode : true,
				keepOrderingOnGrouping : true
			};
			var columnLayout = [
				{
					headerText : "직책",
					dataField : "code_name",
					width : "100%",
					style : "aui-center",
				}
			];
			// 실제로 #grid_wrap 에 그리드 생성
			auiGridCenter = AUIGrid.create("#auiGridCenter", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridCenter, []);
			// 셀클릭 이벤트 바인딩
			AUIGrid.bind(auiGridCenter, "cellClick", cellClickHandler);
		}

		// 결재선목록 그리드
		function createAUIGridRight() {
			var gridPros = {
				// rowIdField 설정
				rowIdField: "sort_no",
				// rowIdField가 unique 임을 보장
				/* rowIdTrustMode: true, */
				// rowNumber
				showRowNumColumn: true,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				//체크박스 출력 여부
				showRowCheckColumn : true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				enableFilter : true,
				// 행 소프트 제거 모드 해제
				softRemoveRowMode : false,
				fillColumnSizeMode : false,
				rowIdTrustMode : true,
				keepOrderingOnGrouping : true,
				editable : true
			};
			var columnLayout = [
				{
					dataField : "sort_no",
					visible : false
				},
				{
					headerText : "결재단계",
					dataField : "seq_no",
					/* width : "10%", */
					style : "aui-center",
					dataType : "numeric",
					editable : false,
					onlyNumeric : true, // 숫자만
				},
				{
					headerText : "직책",
					dataField : "code_name",
					/* width : "70%",  */
					style : "aui-center",
					editable : false
				},
				{
					headerText : "전결여부",
					dataField : "writer_appr_yn",
					renderer : {
						type : "DropDownListRenderer",
						list : dropDownList,
					}
				},
				{
					headerText : "결재순서",
					dataField : "mem_no_sort_no",
					dataType : "numeric",
					formatString : "#,##0",
					editable : true
				}
			];
			// 실제로 #grid_wrap 에 그리드 생성
			auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridRight, []);
			// 셀클릭 이벤트 바인딩
			AUIGrid.bind(auiGridRight, "cellClick", cellClickHandler);
			// 셀 수정 완료 이벤트 바인딩
			AUIGrid.bind(auiGridRight, "cellEditEnd", function(event) {
				// available 수정한 경우만..
				if(event.dataField == "writer_appr_yn") {
					var items = AUIGrid.getItemsByValue(auiGridRight, "seq_no", event.item.seq_no);
					console.log(items);
					for (var i = 0; i < items.length; ++i) {
						var row = {
							sort_no : items[i].sort_no,
							writer_appr_yn : event.value
						}
						AUIGrid.updateRowsById(auiGridRight, row);
					}
				}
				if(event.dataField == "mem_no_sort_no") {
					var items = AUIGrid.getItemsByValue(auiGridRight, "seq_no", event.item.seq_no);
					console.log(items);
					for (var i = 0; i < items.length; ++i) {
						var row = {
							sort_no : items[i].sort_no,
							mem_no_sort_no : event.value
						}
						AUIGrid.updateRowsById(auiGridRight, row);
					}
				}
			});
		}

		// 결재선 목록에 행 추가
		function goAddAppr() {
			// 그리드의 체크된 행들 얻기
			var rows = AUIGrid.getCheckedRowItemsAll(auiGridCenter);
			// 행이 없을 때
			var rowCount = AUIGrid.getRowCount(auiGridRight);
			if(rowCount == 0) {
				apprLevel = 0;
				// 1행 이상일 때
			} else {
				var item = AUIGrid.getItemByRowIndex(auiGridRight, rowCount - 1);
				apprLevel = item.seq_no;
			}
			apprLevel++;
			for(var i = 0, len = rows.length; i < len; i++) {
				rows[i]["seq_no"] = apprLevel;
			}
			if(rows.length <= 0) {
				alert(msg.alert.data.noChecked);
				return;
			}
			console.log(rows, "행 추가");
			// 얻은 행을 결재선 목록 그리드에 추가하기
			AUIGrid.addRow(auiGridRight, rows, "last");
			// 삭제하면  "이동" 이고, 삭제하지 않으면 "복사" 를 구현할 수 있음.
			AUIGrid.removeCheckedRows(auiGridCenter);

		}

		// 결재선 목록에서 행 삭제
		function goRemoveAppr() {
			// 그리드의 체크된 행들 얻기
			var rows = AUIGrid.getCheckedRowItemsAll(auiGridRight);
			if(rows.length <= 0) {
				alert(msg.alert.data.noChecked);
				return;
			}
			console.log(rows, "행 삭제");
			// 얻은 행을 직책 목록 그리드에 추가하기
			AUIGrid.addRow(auiGridCenter, rows, "last");
			// 삭제하면  "이동" 이고, 삭제하지 않으면 "복사" 를 구현할 수 있음.
			AUIGrid.removeCheckedRows(auiGridRight);
			var rowCount = AUIGrid.getRowCount(auiGridRight);
			// 행이 없을 때
			if(rowCount == 0) {
				apprLevel = 0;
				// 행이 1개 이상일 때
			} else {
				var item = AUIGrid.getItemByRowIndex(auiGridRight, rowCount - 1);
				apprLevel = item.seq_no;
			}
		}

		// 셀 클릭으로 엑스트라 체크박스 체크/해제 하기
		function cellClickHandler(event) {
			if (event.dataField != "writer_appr_yn") {
				var item = event.item, rowIdField, rowId;
				rowIdField = AUIGrid.getProp(event.pid, "rowIdField"); // rowIdField 얻기
				rowId = item[rowIdField];
				// 이미 체크 선택되었는지 검사
				if(AUIGrid.isCheckedRowById(event.pid, rowId)) {
					// 엑스트라 체크박스 체크해제 추가
					AUIGrid.addUncheckedRowsByIds(event.pid, rowId);
				} else {
					// 엑스트라 체크박스 체크 추가
					AUIGrid.addCheckedRowsByIds(event.pid, rowId);
				}
			}
		};

		function goCopyApprLine() {
			if($M.getValue('copy_appr_job_cd') == '') {
				alert('해당 업무는 공용이므로, 복사할 수 없습니다.');
				return;
			}
			if(confirm('선택한 업무로 현재 결재라인이 복사됩니다.\n복사하시겠습니까?')) {
				var param = {
					"copy_appr_job_cd" : $M.getValue("copy_appr_job_cd"),
					"copy_org_code" : $M.getValue("copy_org_code"),
					"org_code" : $M.getValue("org_code"),
					"appr_job_cd" : $M.getValue("appr_job_cd")
				};
				$M.goNextPageAjax(this_page+"/copy", $M.toGetParam(param), {method : 'POST'},
						function(result) {
							if(result.success) {
								goSearch();
							}
						}
				);
			}
		}

		function fnChangeAutoAppr() {
			var autoCheck = $M.getValue("auto_appr_yn") == "Y";
			var disable = autoCheck ? "enable" : "disable";

			if(!autoCheck) {
				$M.setValue("auto_appr_cnt", "");
				$M.setValue("appr_org_code_str", "");
				$M.setValue("appr_grade_str", "");
				$M.setValue("appr_mem_str", "");
			}
			$("#auto_appr_cnt").attr("disabled", !autoCheck);
			$('#appr_org_code_str').combogrid(disable);
			$('#appr_grade_str').combogrid(disable);
			$('#appr_mem_str').combogrid(disable);
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
	<input type="hidden" id="cmd" name="cmd" value="C">
	<input type="hidden" id="codeGrid" name="codeGrid" value="C">
	<input type="hidden" id="appr_job_cd" name="appr_job_cd">
	<!-- contents 전체 영역 -->
	<div class="content-wrap">
		<div class="content-box">
			<!-- 메인 타이틀 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
			<!-- /메인 타이틀 -->
			<div class="contents">
				<!-- 검색영역 -->
				<div class="search-wrap">
					<table class="table">
						<colgroup>
							<col width="70px">
							<col width="100px">
						</colgroup>
						<tbody>
						<tr>
							<th>결재업무</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<select class="form-control" id="s_appr_job_cd" name="s_appr_job_cd" style="width:150px">
										<option value="">- 전체 -</option>
										<c:forEach items="${codeMap['APPR_JOB']}" var="item">
											<option value="${item.code_value}">
													${item.code_name}
											</option>
										</c:forEach>
									</select>
								</div>
							</td>
							<td class="">
								<button type="button" onclick="javascript:goSearch('init');" class="btn btn-important" style="width: 50px;">조회</button>
							</td>
						</tr>
						</tbody>
					</table>
				</div>
				<!-- /검색영역 -->
				<div class="row">
					<!-- 결재업무 목록 -->
					<div class="col-6" style="padding-right: 10px;">
						<div class="title-wrap mt10">
							<h4>결재업무 목록</h4>
						</div>
						<div style="margin-top: 5px;" id="auiGridLeft"></div>
						<!-- 그리드 서머리, 컨트롤 영역 -->
						<div class="btn-group mt5">
							<div class="left">
								총 <strong class="text-primary" id="total_cnt">0</strong>건
							</div>
						</div>
						<!-- /그리드 서머리, 컨트롤 영역 -->
					</div>
					<!-- /결재업무 목록 -->
					<div class="col-6">
						<div class="row">
							<!-- 결재업무 정보 -->
							<div class="col-12" style="padding-left: 0">
								<div class="title-wrap mt10">
									<h4>결재업무 정보</h4>
								</div>
								<!-- 폼테이블 -->
								<div>
									<table class="table-border mt5">
										<colgroup>
											<col width="85px"> <!-- 100에서 80 로수정 -> 80에서 85로 수정 -->
											<col width="">
											<col width="80px">
											<col width="">
										</colgroup>
										<tbody>
										<tr>
											<th class="text-right essential-item">결재업무</th>
											<td>
												<input type="text" class="form-control essential-bg" id="appr_job_name" name="appr_job_name" maxlength="100" alt="결재업무" readonly="readonly">
												<input type="hidden" name="appr_job_cd">
											</td>
											<th class="text-right essential-item">결재옵션</th>
											<td>
												<label><input type="radio" name="appr_line_fix_yn" value="Y" onchange="fnChangeApprLineFix()">고정</label>
												<label><input type="radio" name="appr_line_fix_yn" value="N" onchange="fnChangeApprLineFix()">직책별</label>
											</td>
										</tr>
										<tr>
											<th class="text-right essential-item">본인결재<br>가능여부</th>
											<td colspan="3">
												<label><input type="checkbox" id="self_appr_yn" name="self_appr_yn" value="Y">본인 혼자 결재라인에 있을때 결재처리가 가능하게 할지 여부</label>
											</td>
										</tr>
										<tr>
											<th class="text-right essential-item">공용여부</th>
											<td colspan="3">
												<label><input type="checkbox" name="comm_yn" value="Y">부서 공통적용여부, 체크시(모든 부서 동일적용) / 해제시(각부서별 적용)</label>
												<input type="hidden" id="org_code" name="org_code">
												<input type="text" id="org_name" name="org_name" disabled="disabled">
											</td>
										</tr>
										<tr>
											<th class="text-right">결재라인복사</th>
											<td colspan="3">
												<div class="row">
													<div class="col-2" style="line-height: 24px;">현재 결재라인을</div>
													<div class="col-3" style="line-height: 24px;"><select class="form-control" id="copy_appr_job_cd" name="copy_appr_job_cd"></select></div>
													<div class="col-1" style="line-height: 24px; flex: 0 0 5.333333%;">업무</div>
													<div class="col-2" style="line-height: 24px;"><select class="form-control" id="copy_org_code" name="copy_org_code"></select></div>
													<div class="col-1" style="line-height: 24px;">부서로</div>
													<div class="col-2" style="line-height: 24px;"><button type="button" class="btn btn-primary-gra btn-cancel" id="copyBtn" name="copyBtn" onclick="javascript:goCopyApprLine();">복사</button></div>
												</div>
											</td>
										</tr>
										<tr>
											<th class="text-right essential-item">결재라인<br>수정여부</th>
											<td colspan="3">
												<div class="form-check form-check-inline">
													<input class="form-check-input" type="radio" id="line_modify_y" name="line_modify_yn" value="Y">
													<label for="line_modify_y" class="form-check-label">Y</label>
												</div>
												<div class="form-check form-check-inline">
													<input class="form-check-input" type="radio" id="line_modify_n" name="line_modify_yn" value="N">
													<label for="line_modify_n" class="form-check-label">N</label>
												</div>
											</td>
										</tr>
										<tr>
											<th class="text-right essential-item">자동결재여부</th>
											<td colspan="3">
												<input type="checkbox" id="auto_appr_yn" name="auto_appr_yn" value="Y" onchange="javascript:fnChangeAutoAppr()">
												마지막에서 <input type="text" class="essential-bg width30px" id="auto_appr_cnt" name="auto_appr_cnt" alt="자동결재대상수" format="num">번째 인원부터 자동으로 결재할지 여부

											</td>
										</tr>
										<tr>
											<th class="text-right">자동결재<br>권한관리</th>
											<td colspan="3">
												부서권한 <input class="form-control" style="width: 20%;" type="text" id="appr_org_code_str" name="appr_org_code_str" easyui="combogrid"
															easyuiname="orgComboList" panelwidth="300" idfield="org_code" textfield="org_name" multi="Y"/>
												직책 <input class="form-control" style="width: 15%;" type="text" id="appr_grade_str" name="appr_grade_str" easyui="combogrid"
														  easyuiname="gradeComboList" panelwidth="300" idfield="code_value" textfield="code_name" multi="Y"/>
												직원 <input class="form-control" style="width: 20%;" type="text" id="appr_mem_str" name="appr_mem_str" easyui="combogrid"
														  easyuiname="memComboList" panelwidth="300" idfield="mem_no" textfield="mem_name" multi="Y"/>
											</td>
										</tr>
										</tbody>
									</table>
								</div>
								<div class="title-wrap mt10">
									<h4>결재대행</h4>
									<div class="right">
										# 결재대행이 필요한 경우 결재자 대신 대행자가 결재합니다. # 결재자는 수정불가능
										<button type="button" class="btn btn-default" onclick="javascript:fnAdd()">행추가</button>
										<button type="button" class="btn btn-danger" onclick="javascript:goApply()">적용</button>
									</div>
								</div>
								<div id="auiGrid_cover"></div>
								<!-- 고정 -->
								<div id="fixAppr">
									<div class="title-wrap mt10">
										<h4>고정 결재</h4>
									</div>
									<!-- 폼테이블 -->
									<div>
										<table class="table-border mt5">
											<colgroup>
												<col width="80px"> <!-- 100에서 80 로수정-->
												<col width="">
												<col width="120px">
												<col width="">
											</colgroup>
											<tbody>
											<tr>
												<th class="text-right essential-item">고정결재</th>
												<td colspan="3">
													<div class="inline-pd" style="    display: inline-flex;">
														<div class="input-group">
															<input type="text" id="fix_1_mem_name" name="fix_1_mem_name" class="form-control border-right-0 width100px" placeholder="직원조직도" minlength="2" size="20" maxlength="20" alt="" onfocus="fnRemoveFix1()">
															<input type="hidden" id="fix_1_mem_no" name="fix_1_mem_no">
															<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openMemberOrgPanel('setMemFix1', 'N');"><i class="material-iconssearch"></i></button>
															<div style="line-height: 2"><label><input type="checkbox" id="fix_1_writer_appr_yn" name="fix_1_writer_appr_yn">전결 > </label></div>
														</div>
													</div>
													<div class="inline-pd" style="    display: inline-flex;">
														<div class="input-group">
															<input type="text" id="fix_2_mem_name" name="fix_2_mem_name" class="form-control border-right-0 width100px" placeholder="직원조직도" minlength="2" size="20" maxlength="20" alt="" onfocus="fnRemoveFix2()">
															<input type="hidden" id="fix_2_mem_no" name="fix_2_mem_no">
															<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openMemberOrgPanel('setMemFix2', 'N');"><i class="material-iconssearch"></i></button>
															<div style="line-height: 2"><label><input type="checkbox" id="fix_2_writer_appr_yn" name="fix_2_writer_appr_yn">전결 > </label></div>
														</div>
													</div>
													<div class="inline-pd" style="    display: inline-flex;">
														<div class="input-group">
															<input type="text" id="fix_3_mem_name" name="fix_3_mem_name" class="form-control border-right-0 width100px" placeholder="직원조직도" minlength="2" size="20" maxlength="20" alt="" onfocus="fnRemoveFix3()">
															<input type="hidden" id="fix_3_mem_no" name="fix_3_mem_no" value="" alt="">
															<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openMemberOrgPanel('setMemFix3', 'N');"><i class="material-iconssearch"></i></button>
														</div>
													</div>
												</td>
											</tr>
											</tbody>
										</table>
									</div>
								</div>
							</div>
							<!-- 직책별 -->
							<div id="noFixAppr">
								<div class="title-wrap mt10">
									<h4>직책별 결재</h4>
								</div>
								<!-- 폼테이블 -->
								<div>
									<table class="table-border mt5">
										<colgroup>
											<col width="80px"> <!-- 100에서 80 로수정-->
											<col width="">
											<col width="120px">
											<col width="">
										</colgroup>
										<tbody>
										<tr>
											<th class="text-right">최종 결재자</th>
											<td>
												<div class="inline-pd">
													<div class="input-group">
														<input type="search" style="padding: 4px;" id="last_appr_mem_name" name="last_appr_mem_name" class="form-control border-right-0 width120px" value="" placeholder="직원조직도" minlength="2" size="20" maxlength="20">
														<input type="hidden" id="last_appr_mem_no" name="last_appr_mem_no" value="" alt="">
														<button name="__mem_search_btn" type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openMemberOrgPanel('fnSetMemNo', 'N');"><i class="material-iconssearch"></i></button>
													</div>
												</div>
											</td>
										</tr>
										<!-- <tr>

                                        </tr> -->
										</tbody>
									</table>
								</div>
								<!-- /폼테이블 -->
								<div class="row">
									<div class="col-12">
										<div class="title-wrap" style="float:left; width: 40%;">
											<h4>결재 권한 직책 목록</h4>
										</div>
										<div class="title-wrap" style="margin-left:4%; float:left;">
											<h4>결재선 목록</h4>
										</div>
										<div style="margin-top: 5px; height: 150px; display: flex; padding: 0" class="col-12">
											<div style="display: inline-block; width: 40%">
												<div id="auiGridCenter" style="height: 100%;"></div>
											</div>
											<div style="text-align: center; border: 0; vertical-align: middle; float: left; display: inline-block; width: 4%">
												<div style="margin-bottom: 5px; margin-top: 60px;">
													<button type="button" class="btn mint" style="width: 30px;" id="test1"
															onclick="goAddAppr();"><i class="large material-icons">navigate_next</i></button>
												</div>
												<div>
													<button type="button" class="btn mint" style="width: 30px;"
															onclick="goRemoveAppr();"><i class="large material-icons">navigate_before</i></button>
												</div>
											</div>
											<div style="display: inline-block; width: 56%">
												<div id="auiGridRight" style="height: 100%;"></div>
											</div>
										</div>
										<span style="font-size: 11px;">결재순서 : 동일라인에 다수 존재시 사번 빠른 순으로 결정(기본), 다수일때 몇번째 선택함(순서보다 인원이 적을경우 기본 적용)</span>
										<!-- 그리드 서머리, 컨트롤 영역 -->
										<!-- /그리드 서머리, 컨트롤 영역 -->

										<!-- /버튼정보 -->
									</div>
								</div>
							</div>
							<div class="btn-group mt5">
								<div class="right">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
			<!-- /contents 전체 영역 -->
		</div>
		<input type="hidden" id="display_prefix" name="display_prefix">
		<input type="hidden" id="display_postfix" name="display_postfix">
</form>
</body>
</html>