<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 인증관리 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-03-11 15:00:43
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			createAUIGrid();
		});
		
		//엑셀다운로드
		function fnDownloadExcel() {
			var exportProps = {
			    // 제외항목
			    exceptColumnFields : ["isCheck", "remvoeBtn"]
			};
			fnExportExcel(auiGrid, "인증관리", "");
		}
		
		function sendSms(type) {
			var rowsTemp = AUIGrid.getGridData(auiGrid);
			var rows = [];
			for (var i = 0; i < rowsTemp.length; ++i) {
				if (rowsTemp[i].isCheck == true) {
					var found = false;
					for (var j = 0; j < rows.length; ++ j) {
						if (rows[j].mem_no == rowsTemp[i].mem_no) {
							found = true;
						}
					}
					if (found == false) {
						rows.push(rowsTemp[i]);
					}
				}
			}
			if(rows.length == 0) {
				alert("체크된 항목이 없습니다.");
				return false;
			};
			var hps = [];
			var memNos = [];
			var korNames = [];
			for (var i = 0; i < rows.length; ++i) {
				hps.push(rows[i].hp_no);
				memNos.push(rows[i].mem_no);
				korNames.push(rows[i].kor_name);
			};
			var param = {
				hp_no_str : $M.getArrStr(hps),
				mem_no_str : $M.getArrStr(memNos),
				kor_name_str : $M.getArrStr(korNames),
			}
			param["type"] = type;
			$M.goNextPageAjaxMsg(hps.length+"명에게 보내시겠습니까?", this_page + "/send", $M.toGetParam(param), {method : 'POST'}, 
					function(result) {
						if(result.success) {
							AUIGrid.setAllCheckedRows(auiGrid, false);
						} 
					}
				);
		}
		
		// PC다운링크 보내기
		function goSendSmsForPC() {
			sendSms('PC');
		}
		
		// 모바일다운링크 보내기
		function goSendSmsForMobile() {
			sendSms('MOBILE');
		}
		
		function enter(fieldObj) {
			var field = ["s_mem_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}
		
		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				enableCellMerge : true,
				rowIdField : "_$uid",
				showRowNumColumn : true,
				headerHeights : [25, 45],
				// 전체 체크박스 표시 설정
				//체크박스 출력 여부
				/* showRowCheckColumn: true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true, */
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					dataField : "isCheck",
					headerText : "",
					width : "40",
					minWidth : "40",
					headerRenderer : {
						type : "CheckBoxHeaderRenderer",
						// 헤더의 체크박스가 상호 의존적인 역할을 할지 여부(기본값:false)
						// dependentMode 는 renderer 의 type 으로 CheckBoxEditRenderer 를 정의할 때만 활성화됨.
						// true 설정했을 때 클릭하면 해당 열의 필드(데모 상은 isActive 필드)의 모든 데이터를 true, false 로 자동 바꿈
						dependentMode : true, 			
						position : "bottom" // 기본값 "bottom"
					},
					cellMerge : true, // 구분1 셀 세로 병합 실행
					mergeRef : "mem_no", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
					mergePolicy : "restrict",
					renderer : {
						type : "CheckBoxEditRenderer",
						showLabel : false, // 참, 거짓 텍스트 출력여부( 기본값 false )
						editable : true, // 체크박스 편집 활성화 여부(기본값 : false)
					}
				},
				{
					dataField : "app_auth_key",
					visible: false
				},
				{
					headerText: "계정아이디",
				    dataField: "web_id",
					width : "100",
					minWidth : "50",
					cellMerge : true, // 구분1 셀 세로 병합 실행
					mergeRef : "mem_no", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
					mergePolicy : "restrict"
				},
				{
					headerText: "사번",
				    dataField: "mem_no",
					width : "100",
					minWidth : "50",
					cellMerge : true, // 구분1 셀 세로 병합 실행
					mergeRef : "mem_no", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
					mergePolicy : "restrict",
					visible : false
				},
				{
					headerText: "직원구분",
				    dataField: "mem_type_name",
					width : "60",
					minWidth : "30",
					cellMerge : true, // 구분1 셀 세로 병합 실행
					mergeRef : "mem_no", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
					mergePolicy : "restrict"
				},
				{
					headerText: "직원명",
				    dataField: "kor_name",
					width : "60",
					minWidth : "50",
					cellMerge : true, // 구분1 셀 세로 병합 실행
					mergeRef : "mem_no", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
					mergePolicy : "restrict"
				},
				{
					headerText : "부서", 
					dataField : "org_name", 
					width : "70",
					minWidth : "50",
					cellMerge : true, // 구분1 셀 세로 병합 실행
					mergeRef : "mem_no", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
					mergePolicy : "restrict"
				},
				{
					headerText : "직위", 
					dataField : "grade_name", 
					width : "70",
					minWidth : "50",
					cellMerge : true, // 구분1 셀 세로 병합 실행
					mergeRef : "mem_no", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
					mergePolicy : "restrict"
				},
				{
					headerText : "직급",
					dataField : "job_name", 
					width : "70",
					minWidth : "50",
					cellMerge : true, // 구분1 셀 세로 병합 실행
					mergeRef : "mem_no", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
					mergePolicy : "restrict"
				},
				{
					headerText : "휴대전화", 
					dataField : "hp_no", 
					width : "100",
					minWidth : "50",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return $M.phoneFormat(value)
					},
					cellMerge : true, // 구분1 셀 세로 병합 실행
					mergeRef : "mem_no", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
					mergePolicy : "restrict"
				},
				/*
				{
					headerText : "이메일", 
					dataField : "email", 
					width : "100",
					minWidth : "50",
					cellMerge : true, // 구분1 셀 세로 병합 실행
					mergeRef : "mem_no", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
					mergePolicy : "restrict"
				},
				*/
				{
					headerText : "재직구분", 
					dataField : "work_status_name", 
					width : "60",
					minWidth : "50",
					cellMerge : true, // 구분1 셀 세로 병합 실행
					mergeRef : "mem_no", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
					mergePolicy : "restrict"
				},
				
				
				{
					headerText : "PC",
					children: [
						{
							headerText : "브라우저",
							dataField : "pc_browser_name",
							width : "100",
							minWidth : "50",
						},
						{
							headerText : "브라우저버전",
							dataField : "pc_browser_ver",
							width : "100",
							minWidth : "50",
						},
						{
							dataField : "app_auth_pc",
							headerText : "인증적용",
							width : "60",
							minWidth : "60",
							headerRenderer : {
								type : "CheckBoxHeaderRenderer",
								// 헤더의 체크박스가 상호 의존적인 역할을 할지 여부(기본값:false)
								// dependentMode 는 renderer 의 type 으로 CheckBoxEditRenderer 를 정의할 때만 활성화됨.
								// true 설정했을 때 클릭하면 해당 열의 필드(데모 상은 isActive 필드)의 모든 데이터를 true, false 로 자동 바꿈
								dependentMode : true, 			
								position : "bottom" // 기본값 "bottom"
							},
							cellMerge : true, // 구분1 셀 세로 병합 실행
							mergeRef : "mem_no", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
							mergePolicy : "restrict",
							renderer : {
								type : "CheckBoxEditRenderer",
								showLabel : false, // 참, 거짓 텍스트 출력여부( 기본값 false )
								editable : true, // 체크박스 편집 활성화 여부(기본값 : false)
								checkValue : "P",
								unCheckValue : "N"
							},
						},
					]
				},
				{
					headerText : "Mobile",
					children: [
						{
							headerText : "모델명",
							dataField : "mo_model_name",
							width : "100",
							minWidth : "50",
						},
						{
							headerText : "OS버전",
							dataField : "mo_os_ver",
							width : "100",
							minWidth : "50",
						},
						{
							dataField : "app_auth_mo",
							headerText : "인증적용",
							width : "60",
							minWidth : "60",
							headerRenderer : {
								type : "CheckBoxHeaderRenderer",
								// 헤더의 체크박스가 상호 의존적인 역할을 할지 여부(기본값:false)
								// dependentMode 는 renderer 의 type 으로 CheckBoxEditRenderer 를 정의할 때만 활성화됨.
								// true 설정했을 때 클릭하면 해당 열의 필드(데모 상은 isActive 필드)의 모든 데이터를 true, false 로 자동 바꿈
								dependentMode : true, 			
								position : "bottom" // 기본값 "bottom"
							},
							cellMerge : true, // 구분1 셀 세로 병합 실행
							mergeRef : "mem_no", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
							mergePolicy : "restrict",
							renderer : {
								type : "CheckBoxEditRenderer",
								showLabel : false, // 참, 거짓 텍스트 출력여부( 기본값 false )
								editable : true, // 체크박스 편집 활성화 여부(기본값 : false)
								checkValue : "M",
								unCheckValue : "N"
							},
						},
					]
				},
				/*
				{
					headerText : "등록일시",
					dataField : "reg_date",
					width : "140",
					minWidth : "50",
					dataType : "date",
					formatString : "yy-mm-dd HH:MM:ss",
				},
				*/
				{
					headerText : "인증일시",
					dataField : "auth_date",
					width : "140",
					minWidth : "50",
					dataType : "date",
					formatString : "yy-mm-dd HH:MM:ss",
				},
				{
					headerText : "인증앱<br>최종접속일시",
					dataField : "ed_conn_date",
					width : "140",
					minWidth : "50",
					dataType : "date",
					formatString : "yy-mm-dd HH:MM:ss",
				},
				{ 
					headerText : "삭제", 
					dataField : "remvoeBtn", 
					width : "70",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var param = {
								"mem_no" : event.item["mem_no"],
								"app_auth_key" : event.item["app_auth_key"],
								"_$uid" : event.item["_$uid"]
							};
							if (param.app_auth_key == "") {
								alert("인증정보가 없습니다.");
								return false;
							}
							$M.setValue("clickedRowIndex", event.rowIndex);
							goRemove(param);
						},
					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false,
				},
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 셀 수정 완료 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditEnd", function(event) {
				
				// available 칼럼 수정 완료 한 경우
				if(event.dataField == "isCheck" || event.dataField == "app_auth_pc"|| event.dataField == "app_auth_mo") {
					// 체크박스 클릭 했을 때, 병합된 모든 행의 체크박스를 동기화 시킴.
					syncData(event.item, event.rowIndex, event.dataField, "mem_no", event.value);
				}
			});
			AUIGrid.setGridData(auiGrid, []);
			
			AUIGrid.resize(auiGrid);
		}
		
		// 체크박스 클릭 했을 때, 병합된 모든 행의 체크박스를 동기화 시킴.
		function syncData(item, rowIndex, dataField, refDataField, value) {
			var gridData = AUIGrid.getGridData(auiGrid);
			var gridLen = gridData.length;
			var rowIdField = AUIGrid.getProp(auiGrid, "rowIdField");
			var items4update = [];
			var row;
			var obj;

			for(var i=rowIndex+1; i<gridLen; i++) {
				row = gridData[i];
				if(item[refDataField] == row[refDataField]) {
					obj = {};
					obj[rowIdField] = row[rowIdField];
					obj[dataField] = value;
					items4update.push(obj);
				} else {
					break;
				}
			}
			// 동일하게 변경
			AUIGrid.updateRowsById(auiGrid, items4update);
		};
		
		// 조회
		function goSearch() {
			var param = {
				s_mem_name : $M.getValue("s_mem_name"),
				s_org_code : $M.getValue("s_org_code"),
				s_mem_type_cd : $M.getValue("s_mem_type_cd"),
				s_work_status_cd : $M.getValue("s_work_status_cd"),
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$M.setValue("clickedRowIndex", "");
						$("#total_cnt").html(result.total_cnt);
						for (var i = 0; i < result.list.length; ++i) {
							result.list[i]["isCheck"] = false;
						}
						AUIGrid.setGridData(auiGrid, result.list);
						AUIGrid.resize(auiGrid);
					};
				}
			);
		}
		
		// 삭제
		function goRemove(param) {
			$M.goNextPageAjaxMsg("삭제하시겠습니까?", this_page + "/remove", $M.toGetParam(param), {method : 'post'},
				function(result) {
					if(result.success) {
						var rowIndex = $M.getValue("clickedRowIndex");
						var rowItems = AUIGrid.getItemsByValue(auiGrid, "mem_no", param.mem_no);
						if (rowItems.length > 1) {
							AUIGrid.removeRow(auiGrid, rowIndex);
							AUIGrid.removeSoftRows(auiGrid);
							$M.setValue("clickedRowIndex", "");
						} else {
							var item = {
								_$uid : param._$uid,
								pc_browser_name : "",
								pc_browser_ver : "",
								mo_model_name : "",
								mo_os_ver : "",
								reg_date : "",
								auth_date : "",
								app_auth_key : ""
							}
							AUIGrid.updateRowsById(auiGrid, item);
						}
					};
				}
			);
		}
		
		function goSave() {
			var addGridData = AUIGrid.getAddedRowItems(auiGrid);  // 추가내역
			var changeGridData = AUIGrid.getEditedRowItems(auiGrid); // 변경내역
			
			if (changeGridData.length == 0 && addGridData.length == 0) {
				alert("변경내역이 없습니다.");
				return;
			}
			
			var frm = fnChangeGridDataToForm(auiGrid);
			console.log(frm);

			// frm.app_auth_pc 1개일경우 length 사용불가
			if (app_auth_pc.length) {
				for(var i=0, n=frm.app_auth_pc.length; i<n; i++) {
					$M.addValue(frm, 'app_auth_pm', frm.app_auth_pc[i].value + frm.app_auth_mo[i].value);
				}
			} else {
				$M.addValue(frm, 'app_auth_pm', frm.app_auth_pc.value + frm.app_auth_mo.value);
			}
			
			
			$M.goNextPageAjaxSave("/comm/comm0117/save", frm , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("저장이 완료되었습니다.");
		    			goSearch();
					}
				}
			);
		}
		
	</script>
</head>
<body>
	<form id="main_form" name="main_form">
	<input type="hidden" id="clickedRowIndex" name="clickedRowIndex">
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
<!-- 기본 -->					
					<div class="search-wrap">
                        <table class="table">
                            <colgroup>
                                <col width="55px">
                                <col width="120px">
                                <col width="50px">
                                <col width="120px">
                                <col width="75px">
                                <col width="120px">
                                <col width="75px">
                                <col width="120px">
                                <col width="*">
                            </colgroup>
                            <tbody>
                                <tr>							
                                    <th>직원명</th>	
                                    <td>
                                        <input type="text" class="form-control" id="s_mem_name" name="s_mem_name">
                                    </td>
                                    <th>부서</th>
                                    <td>
                                        <input class="form-control" style="width: 99%;"type="text" id="s_org_code" name="s_org_code" easyui="combogrid"
												easyuiname="pathOrgList" panelwidth="350" idfield="org_code" textfield="path_org_name" multi="N"/>
                                    </td>		
                                    <th>직원구분</th>
                                    <td>    
                                        <select class="form-control" id="s_mem_type_cd" name="s_mem_type_cd">
											<option value="">- 전체 -</option>
											<c:forEach var="list" items="${codeMap['MEM_TYPE']}">
												<option value="${list.code_value}">${list.code_name}</option>
											</c:forEach>
										</select>
                                    </td>		
                                    <th>재직구분</th>
                                    <td>    
                                        <select class="form-control" id="s_work_status_cd" name="s_work_status_cd">
											<option value="">- 전체 -</option>
											<c:forEach var="list" items="${codeMap['WORK_STATUS']}">
												<option value="${list.code_value}" <c:if test="${list.code_value eq '01'}">selected</c:if>>${list.code_name}</option>
											</c:forEach>
										</select>
                                    </td>						
                                    <td class="">
                                        <button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
                                    </td>
                                </tr>							
                            </tbody>
                        </table>
                    </div>
<!-- /기본 -->	
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
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
		</div>
<!-- /contents 전체 영역 -->	
		</div>	
	</form>
</body>
</html>