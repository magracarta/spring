<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 자산 > 인사관리 > null > 인사고과
-- 작성자 : 성현우
-- 최초 작성일 : 2020-06-01 10:03:57
-- 사용 안함 : 자동화개발에서 acnt0605p0102.jsp 만 사용하도록 변경
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<style>
		/* by.재호 */
		/* 커스텀 에디터 스타일 */
		#textAreaWrap {
			font-size: 12px;
			position: absolute;
			height: 100px;
			min-width: 100px;
			background: #fff;
			border: 1px solid #555;
			display: none;
			padding: 4px;
			text-align: right;
			z-index: 9999;
		}

		#textAreaWrap textarea {
			font-size: 12px;
		}
	</style>
	<script type="text/javascript">

		var auiGridYearEval; // 인사고과서
		var auiGridEvalBand; // 평가밴드
		var auiGridAwardAndPenalty; // 상벌사항

		var hrAbilityListJson = ${hrAbilityList}; // 인사능력(서비스부 외)
		var hrJobListJson = ${hrJobList}; // 직책수당
		var hrLangListJson = ${hrLangList}; // 언어수당
		var memYearEval = ${memYearEval};
		$(document).ready(function () {
			// 인사고과서 그리드 생성
			createAUIGridYearEval();
			// 평가밴드 그리드 생성
			createAUIGridEvalBand();
			// 상벌사항 그리드 생성
			createAUIGridAwardAndPenalty();

			// // by.재호
			// // textarea 확인
			// $("#confirmBtn").click(function (event) {
			// 	var value = $("#myTextArea").val();
			// 	forceEditngTextArea(value);
			// });
			//
			// // by.재호
			// // textarea 취소
			// $("#cancelBtn").click(function (event) {
			// 	$("#textAreaWrap").hide();
			// });

			// by.재호
			// textarea blur
			$("#myTextArea").blur(function (event) {
				var relatedTarget = event.relatedTarget || document.activeElement;
				var $relatedTarget = $(relatedTarget);

				// 확인 버튼 클릭한 경우
				// if ($relatedTarget.is("#confirmBtn")) {
				// 	return;
				// } else if ($relatedTarget.is("#cancelBtn")) { // 취소 버튼
				// 	return;
				// }

				forceEditngTextArea(this.value);
			});

			
			fnInit();
		});

		// by. 재호
		// 진짜로 textarea 값을 그리드에 수정 적용시킴
		function forceEditngTextArea(value) {
			var dataField = $("#textAreaWrap").data("data-field"); // 보관한 dataField 얻기
			var rowIndex = Number($("#textAreaWrap").data("row-index")); // 보관한 rowIndex 얻기
			value = value.replace(/\r|\n|\r\n/g, "<br/>"); // 엔터를 BR태그로 변환
			//value = value.replace(/\r|\n|\r\n/g, " "); // 엔터를 공백으로 변환

			var item = {};
			item[dataField] = value;

			AUIGrid.updateRow(auiGridYearEval, item, rowIndex);
			$("#textAreaWrap").hide();
		};

		// by. 재호
		// 커스텀 에디팅 렌더러 유형에 맞게 출력하기
		function createMyCustomEditRenderer(event) {

			var dataField = event.dataField;
			var $obj;
			var $textArea;
			// title, content는  TextArea 사용
			if (dataField == "self_eval_text" || dataField == "boss_eval_text" || dataField == "mng_eval_text" || dataField == "last_eval_text") {
				$obj = $("#textAreaWrap").css({
					left: event.position.x,
					top: event.position.y,
					width: event.size.width - 8, // 8는 textAreaWrap 패딩값
					height: 120
				}).show();
				$textArea = $("#myTextArea").val(String(event.value).replace(/[<]br[/][>]/gi, "\r\n"));

				// 데이터 필드 보관
				$obj.data("data-field", dataField);
				// 행인덱스 보관
				$obj.data("row-index", event.rowIndex);

				// 포커싱
				setTimeout(function () {
					$textArea.focus();
					$textArea.select();
				}, 16);
			}
		}

		function fnInit() {
			var menuShowYn = $M.getValue("menu_show_yn");
			var memNo = $M.getValue("mem_no");
			var secureMemNo = "${SecureUser.mem_no}";
			var apprProcStatusCd = $M.toNum($M.getValue("appr_proc_status_cd"));

			// 직장, 기사만 평가하기가 보여지도록
			if ("N" == menuShowYn) {
				AUIGrid.hideColumnByDataField(auiGridEvalBand, ["service_ability_code"]);
			} else {
				AUIGrid.hideColumnByDataField(auiGridEvalBand, ["normal_ability_code"]);
			}

			if (memYearEval.mng_eval_yn == "N") {
				var hideList = ["mng_eval_text"];
				AUIGrid.hideColumnByDataField(auiGridYearEval, hideList);
			}

			if (memYearEval.boss_mem_no == "") {
				var hideList = ["boss_eval_text"];
				AUIGrid.hideColumnByDataField(auiGridYearEval, hideList);
			}

			// 본인이 아닌 경우
			if (memNo != secureMemNo) {
				$("#_goRequestApproval").addClass("dpn");
				$("#_goSave").addClass("dpn");
			}

			// 결재요청을 한 경우(결재중인 경우)
			if (apprProcStatusCd >= 3) {
				$("#_goRequestApproval").addClass("dpn");
				$("#_goSave").addClass("dpn");
			}
		}

		// 능력 레벨 설정 (서비스)
		function fnServicePopup(rowIndex) {
// 			if (hrAbilityListJson.length == 0) {
// 				alert("소속된 직군이 없거나,\n직군의 레벨범위가 설정되어있지 않습니다.\n[공통 > 인사코드관리(능력)]에서 설정 후 진행해주세요.");
// 				return;
// 			}
			
			$M.setValue("service_ability_rowIndex", rowIndex);

			var item = AUIGrid.getItemByRowIndex(auiGridEvalBand, rowIndex);
			var params = {
				"mem_no" : $M.getValue("mem_no"),
				"eval_year" : $M.getValue("s_eval_year"),
				"biz_code" : item.service_ability_code,
				"salary_amt" : item.ability_amt,
				"seq_no" : item.svc_ability_eval_seq_no,
				"curr_seq_no" : item.curr_seq_no,
				"want_seq_no" : item.want_seq_no,
				"up_seq_no" : item.up_seq_no,
				"adjust_seq_no" : item.adjust_seq_no,
				"level_index" : rowIndex,
				"appr_job_seq" : $M.getValue("appr_job_seq"),
				"parent_js_name" : "fnSetServiceAbility",
			};

			var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=300, height=200, left=0, top=0";
			$M.goNextPage('/acnt/acnt0601p0108', $M.toGetParam(params), {popupStatus: popupOption});
		}

		// 능력 레벨 설정 (서비스)
		function fnSetServiceAbility(data) {
			var rowIndex = $M.getValue("service_ability_rowIndex");
			AUIGrid.updateRow(auiGridEvalBand, {"service_ability_code": data.biz_code}, rowIndex);
			AUIGrid.updateRow(auiGridEvalBand, {"ability_amt": data.salary_amt}, rowIndex);
			AUIGrid.updateRow(auiGridEvalBand, {"svc_ability_eval_seq_no": data.seq_no}, rowIndex);

			var item = AUIGrid.getItemByRowIndex(auiGridEvalBand, rowIndex);
			fnCalcWantSalaryAmt(item);
		}

		// 희망연봉 계산
		function fnCalcWantSalaryAmt(item) {

			// 언어수당 금액
			var langAmt = $M.toNum(item.lang_amt);
			// 직챙수당 금액
			var jobAmt = $M.toNum(item.job_amt);
			// 능력 금액
			var abilityAmt = $M.toNum(item.ability_amt);

			// 희망연봉 계산
			var wantSalaryAmt = langAmt + jobAmt + abilityAmt;
			$M.setValue("want_salary_amt", wantSalaryAmt);
		}

		function fnChangeEvalYear() {
			if (confirm("조회년도를 변경하시겠습니까?\n변경 시 기존에 작성하던 내용이 초기화됩니다.") == false) {
				$M.setValue("s_eval_year", ${inputParam.s_eval_year});
				return false;
			}

			goSearch();
		}

		// 조회
		function goSearch() {
			var params = {
				"s_eval_year": $M.getValue("s_eval_year"),
				"s_mem_no": $M.getValue("mem_no")
			};

			var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=400, height=300, left=0, top=0";
			$M.goNextPage(this_page + "/" + $M.getValue("mem_no"), $M.toGetParam(params), {method: "GET"});
		}

		// 결재요청
		function goRequestApproval() {
			goSave('requestAppr');
		}

		// 저장
		function goSave(isRequestAppr) {
			var msg = "";
			if (isRequestAppr != undefined) {
				if("N" == $M.getValue("write_end_yn")) {
					alert("실적평가를 작성완료해야 결재요청을 진행할 수 있습니다.");
					return;
				}
				// 결재요청 Setting
				$M.setValue("save_mode", "appr");
				msg = "결재요청 하시겠습니까?";
			} else {
				$M.setValue("save_mode", "save");
				msg = "저장 하시겠습니까?";
			}

			// 인사고과서 및 평가밴드 내용 확인
			if(isRequestAppr != undefined) {
				var yearEvalData = AUIGrid.getGridData(auiGridYearEval);
				var evalBandData = AUIGrid.getGridData(auiGridEvalBand);

				// 인사고과서 Check
				for(var i=0; i<yearEvalData.length; i++) {
					if(yearEvalData[i].self_eval_text == "") {
						alert("인사고과서 본인평가는 모두 필수로 입력해야합니다.");
						return;
					}
				}

				// 평가밴드 Check
				for(var i=0; i<evalBandData.length; i++) {
					if("Y" == $M.getValue("menu_show_yn")) {
						if(evalBandData[i].mem_band_item_cd == "02" && evalBandData[i].service_ability_code == "") {
							alert("평가밴드 능력레벨은 필수로 입력해야합니다.");
							return;
						}
					} else {
						if(evalBandData[i].mem_band_item_cd == "02" && evalBandData[i].normal_ability_code == "") {
							alert("평가밴드 능력레벨은 필수로 입력해야합니다..");
							return;
						}
					}

				}
			}

			var frm = $M.toValueForm(document.main_form);

			var concatCols = [];
			var concatList = [];
			var gridIds = [auiGridYearEval, auiGridEvalBand];
			for (var i = 0; i < gridIds.length; ++i) {
				concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
				concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
			}

			var gridFrm = fnGridDataToForm(concatCols, concatList);
			$M.copyForm(gridFrm, frm);

			$M.goNextPageAjaxMsg(msg, this_page + "/save", gridFrm, {method: "POST"},
					function (result) {
						if (result.success) {
							window.location.reload();
						}
					}
			);
		}

		// 닫기
		function fnClose() {
			top.window.close();
		}

		// 그리드 핸들러
		function auiCellEditHandler(event) {
			switch (event.type) {
				case "cellEditBegin" :
					// 희망레벨만 수정 가능
					if (event.item.mem_band_item_cd != "02") {
						if (event.dataField == "mem_band_item_name" || event.dataField == "normal_ability_code"
								|| event.dataField == "job_code" || event.dataField == "lang_code") {
							return false;
						}
					}
					
					// 2021-10-26 능력레벨 선택전에 해당 직원이 소속된 직군이 없다면 메시지
					if (event.dataField == "normal_ability_code") {
						if ($M.getValue("job_grp_cd") == '') {
							setTimeout(function() {
								   AUIGrid.showToastMessage(auiGridEvalBand, event.rowIndex, event.columnIndex, "소속된 직군이 없습니다.");
							}, 1);
							return false;
						}

						if ($M.getValue("job_grp_cd") != '' && hrAbilityListJson.length == 0) {
							setTimeout(function() {
								   AUIGrid.showToastMessage(auiGridEvalBand, event.rowIndex, event.columnIndex, "소속된 직군의 레벨범위를 설정 해 주세요.");
							}, 1);
							return false;
						}
					}
					break;
				case "cellEditEnd" :
					if (event.dataField == "lang_code" || event.dataField == "job_code"
							|| event.dataField == "normal_ability_code" || event.dataField == "service_ability_code") {

						// 금액 계산
						fnCalcWantSalaryAmt(event.item);
					}
					break;
			}
		}

		// 인사고과서 그리드 생성
		function createAUIGridYearEval() {
			var gridPros = {
				rowIdField: "_$uid",
				editable: true,
				showStateColumn: true,
				showRowNumColumn: false,
				rowHeight: 40,
				// 자동 줄 개행 (퍼포먼스에 영향이 크다고 합니다.)
				wordWrap: true
				};

			// 결재요청 후 부터는 수정 X
			if($M.toNum($M.getValue("appr_proc_status_cd")) >= 3) {
				gridPros.editable = false;
			}

			var columnLayout = [
				{
					headerText: "항목",
					dataField: "mem_eval_item_name",
					editable: false,
					width: "160",
					minWidth: "150",
					style: "aui-center"
				},
				{
					headerText: "본인평가",
					dataField: "self_eval_text",
					width: "400",
					minWidth: "390",
					renderer: {
						type: "TemplateRenderer"
					},
					// style: "aui-left aui-editable"
				},
				{
					headerText: "상사평가",
					dataField: "boss_eval_text",
					width: "400",
					minWidth: "390",
					style: "aui-left",
					editable: false,
					renderer: {
						type: "TemplateRenderer"
					},
					styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
						return "aui-background-darkgray";
					}
				},
				{
					headerText: "매니저평가",
					dataField: "mng_eval_text",
					width: "400",
					minWidth: "390",
					style: "aui-left",
					editable: false,
					renderer: {
						type: "TemplateRenderer"
					},
					styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
						return "aui-background-darkgray";
					}
				},
				{
					headerText: "최종평가",
					dataField: "last_eval_text",
					width: "400",
					minWidth: "390",
					style: "aui-left",
					editable: false,
					renderer: {
						type: "TemplateRenderer"
					},
					styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
						return "aui-background-darkgray";
					}
				},
				{
					headerText: "항목",
					dataField: "mem_eval_item_cd",
					visible: false
				},
				{
					headerText: "cmd",
					dataField: "eval_cmd",
					visible: false
				}
			];

			auiGridYearEval = AUIGrid.create("#auiGridYearEval", columnLayout, gridPros);

			// by. 재호
			// 에디팅 시작 이벤트 바인딩
			AUIGrid.bind(auiGridYearEval, "cellEditBegin", function (event) {
				// 클립보드 붙여 넣기인 경우는 패스함.
				if (event.isClipboard) {
					return true;
				}
				// 커스템 에디터 출력
				createMyCustomEditRenderer(event);
				return false; // 수정 input 열지 않고 오로지 textarea 로 수정하게끔 함
			});

			AUIGrid.setGridData(auiGridYearEval, memYearEvalListJson);
			$("#auiGridYearEval").resize();
		}

		// 평가밴드 그리드 생성
		function createAUIGridEvalBand() {
			var gridPros = {
				rowIdField: "_$uid",
				editable: true,
				showRowNumColumn: false,
				showStateColumn: true
			};

			// 결재요청 후 부터는 수정 X
			if($M.toNum($M.getValue("appr_proc_status_cd")) >= 3) {
				gridPros.editable = false;
			}

			var columnLayout = [
				{
					headerText: "구분",
					dataField: "mem_band_item_name",
					width: "100",
					minWidth: "90",
					style: "aui-center"
				},
				{
					headerText: "능력",
					children: [
						{
							headerText: "레벨",
							dataField: "normal_ability_code",
							width: "100",
							minWidth: "90",
							style: "aui-center aui-editable",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								var retStr = "";
								for (var i = 0, len = hrAbilityListJson.length; i < len; i++) {
									if (hrAbilityListJson[i]["biz_code"] == value) {
										retStr = hrAbilityListJson[i]["biz_code"];

										// 직책수당 금액 설정
										AUIGrid.updateRow(auiGridEvalBand, {"ability_amt": hrAbilityListJson[i].salary_amt}, rowIndex);
										break;
									}
								}
								return retStr == "" ? value : retStr;
							},
							editRenderer: {
								type: "DropDownListRenderer",
								showEditorBtnOver: true, // 마우스 오버 시 에디터버턴 보이기
								keyField: "biz_code",
								valueField: "biz_code",
								list: hrAbilityListJson,
								// 드랍 리스트의 개별 아이템에 대하여 출력할 양식을 HTML 로 작성하여 반환하면 리스트로 출력됩니다.
								listTemplateFunction: function (rowIndex, columnIndex, text, item, dataField, listItem) {
									var html = '<div style="display:block;text-align:left;white-space:nowrap">';
									for (var n in listItem) {
										if (n != "flag") {
											html += '<span style="display:inline-block;width:80px;">' + listItem[n] + '</span>';
										}
									}
									html += '</div>';
									return html;
								}
							}
						},
						{
							headerText: "레벨",
							dataField: "service_ability_code",
							width: "100",
							minWidth: "90",
							editable: false,
							renderer : { // HTML 템플릿 렌더러 사용
								type : "TemplateRenderer"
							},
							labelFunction : function( rowIndex, columnIndex, value, dataField, item) {
								var template = '<div>' + '<span style="color:black; cursor: pointer; text-decoration: underline;" onclick="javascript:fnServicePopup(' + rowIndex + ');">' + "평가하기" + '</span>' + '</div>';

								if (item.mem_band_item_cd != "02") {
									template = value;
								}

								if (item.mem_band_item_cd == "02" && value != "") {
									template = '<div>' + '<span style="color:black; cursor: pointer; text-decoration: underline;" onclick="javascript:fnServicePopup(' + rowIndex + ');">' + value + '</span>' + '</div>';
								}

								return template;
							}
						},
						{
							headerText: "금액",
							dataField: "ability_amt",
							dataType: "numeric",
							formatString: "#,##0",
							width: "100",
							minWidth: "90",
							style: "aui-right",
							editable: false
						},
					]
				},
				{
					headerText: "직책수당",
					children: [
						{
							headerText: "레벨",
							dataField: "job_code",
							width: "100",
							minWidth: "90",
							style: "aui-center aui-editable",
							editable : false,
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								var retStr = "";
								for (var i = 0, len = hrJobListJson.length; i < len; i++) {
									if (hrJobListJson[i]["biz_code"] == value) {
										retStr = hrJobListJson[i]["biz_code"];

										// 직책수당 금액 설정
										AUIGrid.updateRow(auiGridEvalBand, {"job_amt": hrJobListJson[i].year_benefit_amt}, rowIndex);
										break;
									}
								}
								return retStr == "" ? value : retStr;
							},
// 							editRenderer: {
// 								type: "DropDownListRenderer",
// 								showEditorBtnOver: true, // 마우스 오버 시 에디터버턴 보이기
// 								keyField: "biz_code",
// 								valueField: "biz_code",
// 								list: hrJobListJson,
// 								// 드랍 리스트의 개별 아이템에 대하여 출력할 양식을 HTML 로 작성하여 반환하면 리스트로 출력됩니다.
// 								listTemplateFunction: function (rowIndex, columnIndex, text, item, dataField, listItem) {
// 									var html = '<div style="display:block;text-align:left;white-space:nowrap">';
// 									for (var n in listItem) {
// 										if (n != "flag") {
// 											html += '<span style="display:inline-block;width:80px;">' + listItem[n] + '</span>';
// 										}
// 									}
// 									html += '</div>';
// 									return html;
// 								}
// 							},
							renderer : { // HTML 템플릿 렌더러 사용
								type : "TemplateRenderer"
							},
							labelFunction : function( rowIndex, columnIndex, value, dataField, item) {
								console.log(item);
								var template = '<div>' + '<span style="color:black; cursor: pointer; text-decoration: underline;" onclick="javascript:fnHrJobPopup(' + rowIndex + ', ' + item.mem_band_item_cd + ');">' + "평가하기" + '</span>' + '</div>';

								if (item.mem_band_item_cd != "02") {
									template = value;
								}

								if (item.mem_band_item_cd == "02" && value != "") {
									template = '<div>' + '<span style="color:black; cursor: pointer; text-decoration: underline;" onclick="javascript:fnHrJobPopup(' + rowIndex + ', ' + item.mem_band_item_cd + ');">' + value + '</span>' + '</div>';
								}

								return template;
							}
						},
						{
							headerText: "금액",
							dataField: "job_amt",
							dataType: "numeric",
							formatString: "#,##0",
							width: "100",
							minWidth: "90",
							style: "aui-right",
							editable: false
						},
					]
				},
				{
					headerText: "언어수당",
					children: [
						{
							headerText: "레벨",
							dataField: "lang_code",
							width: "100",
							minWidth: "90",
							style: "aui-center aui-editable",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								var retStr = "";
								for (var i = 0, len = hrLangListJson.length; i < len; i++) {
									if (hrLangListJson[i]["biz_code"] == value) {
										retStr = hrLangListJson[i]["biz_code"];

										// 언어수당 금액 설정
										AUIGrid.updateRow(auiGridEvalBand, {"lang_amt": hrLangListJson[i].year_benefit_amt}, rowIndex);
										break;
									}
								}
								return retStr == "" ? value : retStr;
							},
							editRenderer: {
								type: "DropDownListRenderer",
								showEditorBtnOver: false, // 마우스 오버 시 에디터버턴 보이기
								keyField: "biz_code",
								valueField: "biz_code",
								list: hrLangListJson,
								// 드랍 리스트의 개별 아이템에 대하여 출력할 양식을 HTML 로 작성하여 반환하면 리스트로 출력됩니다.
								listTemplateFunction: function (rowIndex, columnIndex, text, item, dataField, listItem) {
									var html = '<div style="display:block;text-align:left;white-space:nowrap">';
									for (var n in listItem) {
										if (n != "flag") {
											html += '<span style="display:inline-block;width:80px;">' + listItem[n] + '</span>';
										}
									}
									html += '</div>';
									return html;
								}
							}
						},
						{
							headerText: "금액",
							dataField: "lang_amt",
							dataType: "numeric",
							formatString: "#,##0",
							width: "100",
							minWidth: "90",
							style: "aui-right",
							editable: false
						},
					]
				},
				{
					headerText: "평가일자",
					dataField: "eval_dt",
					dataType: "date",
					formatString: "yyyy-mm-dd",
					width: "100",
					minWidth: "90",
					style: "aui-center",
					editable: false
				},
				{
					headerText: "구분",
					dataField: "mem_band_item_cd",
					visible: false
				},
				{
					headerText: "cmd",
					dataField: "band_cmd",
					visible: false
				},
				{
					headerText: "서비스능력평가순번",
					dataField: "svc_ability_eval_seq_no",
					visible: false
				},
				{
					headerText: "서비스능력평가순번(현재)",
					dataField: "curr_seq_no",
					visible: false
				},
				{
					headerText: "서비스능력평가순번(희망)",
					dataField: "want_seq_no",
					visible: false
				},
				{
					headerText: "서비스능력평가순번(상사)",
					dataField: "up_seq_no",
					visible: false
				},
				{
					headerText: "서비스능력평가순번(조정)",
					dataField: "adjust_seq_no",
					visible: false
				}
			];

			auiGridEvalBand = AUIGrid.create("#auiGridEvalBand", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridEvalBand, memEvalBandListJson);
			$("#auiGridEvalBand").resize();

			AUIGrid.bind(auiGridEvalBand, "cellEditBegin", auiCellEditHandler);
			AUIGrid.bind(auiGridEvalBand, "cellEditEnd", auiCellEditHandler);
		}

		// 상벌사항 그리드 생성
		function createAUIGridAwardAndPenalty() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn: true,
				showStateColumn: false
			};

			var columnLayout = [
				{
					headerText: "반영일자",
					dataField: "apply_dt",
					dataType: "date",
					formatString: "yyyy-mm-dd",
					width: "80",
					minWidth: "70",
					style: "aui-center"
				},
				{
					headerText: "구분",
					dataField: "mem_penalty_name",
					width: "60",
					minWidth: "50",
					style: "aui-center"
				},
				{
					headerText: "등급",
					dataField: "code_name",
					width: "70",
					minWidth: "60",
					style: "aui-center"
				},
				{
					headerText: "속성",
					dataField: "doc_type_name",
					width: "70",
					minWidth: "60",
					style: "aui-center"
				},
				{
					headerText: "비고",
					dataField: "remark",
					width: "180",
					minWidth: "170",
					style: "aui-left"
				},
				{
					headerText: "사유서",
					dataField: "origin_file_name_1",
					width: "100",
					minWidth: "90",
					editable: false,
					renderer: { // HTML 템플릿 렌더러 사용
						type: "TemplateRenderer"
					},
					labelFunction: function (rowIndex, columnIndex, value, dataField, item) {
						var template = '<div>' + '<span style="color:black; cursor: pointer; text-decoration: underline;" onclick="javascript:fileDownload(' + item.doc_file_seq_1 + ');">' + value + '</span>' + '</div>';
						return template;
					}
				},
				{
					headerText: "첨부파일명",
					dataField: "doc_file_seq_1",
					visible: false
				}
			];

			auiGridAwardAndPenalty = AUIGrid.create("#auiGridAwardAndPenalty", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridAwardAndPenalty, awardAndPenaltyListJson);
			$("#auiGridAwardAndPenalty").resize();
		}
		
		// 크게보기 추가 210714 이강원
		function goLarge(){
			var total_eval_cnt = 4;
			if(memYearEval.mng_eval_yn == 'N'){
				total_eval_cnt--;
			}
			if(memYearEval.boss_mem_no == ""){
				total_eval_cnt--;
			}
			
			var params = {
				"s_mem_no": $M.getValue("mem_no"),
				"mng_eval_yn": memYearEval.mng_eval_yn,
				"boss_mem_no": memYearEval.boss_mem_no,
				"s_eval_year": $M.getValue("s_eval_year"),
				"total_eval_cnt": total_eval_cnt,
			};
			
			var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=700, left=0, top=0";
			$M.goNextPage(this_page + "01", $M.toGetParam(params), {popupStatus : popupOption});
		}

		// 리사이징이 일어난 경우 커스텀 렌더러 없앰.
		$(window).resize(function() {
			$("#textAreaWrap").hide();
		});

		// 평가밴드 - 직책 레벨
		function fnHrJobPopup(rowIndex, bandCd) {
			console.log("bandCd : ", bandCd);
			var param = {
					"level_index" : rowIndex,
					"mem_result_eval_no" : $M.getValue("mem_result_eval_no"),
					"mem_band_item_cd" : "0"+bandCd,
					"appr_job_seq" : $M.getValue("appr_job_seq"),
					"mem_no" : $M.getValue("mem_no"),
					"parent_js_name" : "fnSetServiceJob",
			}
			var popupOption = "";
			$M.goNextPage('/comm/comm0120p04', $M.toGetParam(param), {popupStatus : popupOption});
		}
		
		// 평가밴드 - 직책 레벨 데이터 리턴
		function fnSetServiceJob(data) {
			// 직책레벨, 금액 세팅
			AUIGrid.updateRow(auiGridEvalBand, data, data.rowIndex);
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<!-- 직원번호 -->
	<input type="hidden" id="mem_no" name="mem_no" value="${memInfo.mem_no}"/>
	<input type="hidden" id="job_grp_cd" name="job_grp_cd" value="${memInfo.job_grp_cd}"/>
	<!-- 업무구분코드 -->
	<input type="hidden" id="work_gubun_cd" name="work_gubun_cd" value="${memInfo.work_gubun_cd}"/>
	<!-- 업무결재번호 -->
	<input type="hidden" id="appr_job_seq" name="appr_job_seq" value="${memResultEvalInfo.appr_job_seq}"/>
	<!-- 결재진행상태 -->
	<input type="hidden" id="appr_proc_status_cd" name="appr_proc_status_cd" value="${memResultEvalInfo.appr_proc_status_cd}"/>
	<!-- 직원인사고과번호 -->
	<input type="hidden" id="mem_result_eval_no" name="mem_result_eval_no" value="${memResultEvalInfo.mem_result_eval_no}"/>
	<!-- 희망연봉 -->
	<input type="hidden" id="want_salary_amt" name="want_salary_amt" value="${memResultEvalInfo.want_salary_amt}"/>
	<!-- 실적평가 작성여부 -->
	<input type="hidden" id="write_end_yn" name="write_end_yn" value="${memResultEvalInfo.write_end_yn}" />
	<!-- 직장,기사 판단여부 -->
	<input type="hidden" id="menu_show_yn" name="menu_show_yn" value="${inputParam.menu_show_yn}" />

	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<div>
			<!-- 탭내용 -->
			<div class="tabs-inner-line">
				<div class="boxing bd0 pd0 vertical-line mt5">
					<div class="tabs-search-wrap">

						<table class="table table-fixed">
							<colgroup>
								<col width="60px">
								<col width="80px">
								<col width="*">
							</colgroup>
							<tbody>
							<tr>
								<th>조회년도</th>
								<td>
									<select class="form-control" id="s_eval_year" name="s_eval_year" required="required" alt="조회년도" onchange="javascript:fnChangeEvalYear();">
										<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
											<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
											<option value="${year_option}" <c:if test="${year_option eq inputParam.s_eval_year}">selected</c:if>>${year_option}년</option>
										</c:forEach>
									</select>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
				</div>
			</div>
			<!-- /탭내용 -->
			<!-- 인사고과서 -->
			<div class="title-wrap mt10">
				<div class="left approval-left">
					<div style="width:200px;">
						<h4 style="display:inline-block;">인사고과서</h4>
						<button type="button" class="btn btn-info material-iconsadd" style="display:inline-block;" onclick="javascript:goLarge()">크게보기</button>
					</div>
					<!-- 결재영역 -->
					<div class="p10" style="margin-left: 10px;">
						<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
					</div>
					<!-- /결재영역 -->
				</div>
			</div>
			<div id="auiGridYearEval" style="margin-top: 5px; height: 190px;"></div>
			<!-- /인사고과서 -->
			<div class="row">
				<div class="col-6">
					<!-- 평가밴드 -->
					<div class="title-wrap mt10">
						<h4>평가밴드</h4>
					</div>
					<div id="auiGridEvalBand" style="margin-top: 5px; height: 220px;"></div>
					<div>
						<table class="table-border mt5">
							<colgroup>
								<col width="100px">
								<col width="*">
							</colgroup>
							<tbody>
							<tr>
								<th class="title-bg">현재연봉</th>
								<td class="td-link">
									<input type="text" class="form-control text-left" id="curr_salary_amt" name="curr_salary_amt" format="decimal" alt="현재연봉" readonly="readonly" value="${info.curr_salary_amt}">
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /평가밴드 -->
				</div>
				<div class="col-6">
					<!-- 상벌사항 -->
					<div class="title-wrap mt10">
						<h4>상벌사항</h4>
					</div>
					<div id="auiGridAwardAndPenalty" style="margin-top: 5px; height: 150px;"></div>
					<!-- /상벌사항 -->
					<!-- 결재자의견 -->
					<div class="title-wrap mt10">
						<h4>결재자의견</h4>
					</div>
					<table class="table mt5">
						<colgroup>
							<col width="40px">
							<col width="">
							<col width="60px">
							<col width="">
						</colgroup>
						<thead>
						<tr>
							<td colspan="5">
								<div class="fixed-table-container" style="width: 100%; height: 110px;">
									<!-- height값 인라인 스타일로 주면 타이틀 영역이 고정됨  -->
									<div class="fixed-table-wrapper">
										<table class="table-border doc-table md-table">
											<colgroup>
												<col width="40px">
												<col width="140px">
												<col width="55px">
												<col width="">
											</colgroup>
											<thead>
											<!-- 퍼블리싱 파일의 important 속성 때문에 dev에 선언한 클래스가 안되서 인라인 CSS로함 -->
											<tr>
												<th class="th" style="font-size: 12px !important">구분</th>
												<th class="th" style="font-size: 12px !important">결재일시</th>
												<th class="th" style="font-size: 12px !important">담당자</th>
												<th class="th" style="font-size: 12px !important">특이사항</th>
											</tr>
											</thead>
											<tbody>
											<c:forEach var="list" items="${apprMemoList}">
												<tr>
													<td class="td" style="text-align: center; font-size: 12px !important">${list.appr_status_name }</td>
													<td class="td" style="font-size: 12px !important">${list.proc_date }</td>
													<td class="td" style="text-align: center; font-size: 12px !important">${list.appr_mem_name }</td>
													<td class="td" style="font-size: 12px !important">${list.memo }</td>
												</tr>
											</c:forEach>
											</tbody>
										</table>
									</div>
								</div>
							</td>
						</tr>
						</tbody>
					</table>
					<!-- /결재자의견 -->
				</div>
			</div>
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
		</div>
	</div>
	<!-- /팝업 -->
	<!-- 사용자 정의 렌더러 - html textarea 태그 -->
	<div id="textAreaWrap">
		<textarea id="myTextArea" class="aui-grid-custom-renderer-ext" style="width:100%; height:90px;"></textarea>
	</div>
</form>
</body>
</html>