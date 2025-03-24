<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 고객연관팝업 > 고객연관팝업 > null > 사업자명세
-- 작성자 : 김태훈
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var auiGrid;
		var cust_no;
		
		$(document).ready(function() {
			createAUIGrid();
			fnSetCustInfo();
		});	
		
		// 사업자정보조회에서 가져온 데이터를 고객에 사업자번호로 즉시 등록
		function goSave(row) {
			var list = AUIGrid.getGridData(auiGrid);
			for (var i = 0; i < list.length; ++i) {
				if (list[i].breg_seq == row.breg_seq) {
					alert("이미 등록된 사업자 정보입니다.");
					return false;
				}
			}
			$M.goNextPageAjax(this_page+"/"+$M.getValue("cust_no")+"/"+row.breg_seq, '', {method : 'post'},
					function(result) {
						if(result.success) {
							AUIGrid.addRow(auiGrid, row, 'last');
						};
					}
				)
		};
		
		function fnSetCustInfo() {
			// 새로고침할때 유지되게 hidden text에 넣음
			try {
				var origin = ${cust};
				$M.setValue("cust_no", origin.cust_no);
				$M.setValue("hp_no", origin.hp_no);
				$M.setValue("cust_name", origin.cust_name);
				$("#cust_info").html($M.getValue("cust_name")+"("+$M.getValue("hp_no")+")");	
			} catch (e) {
				console.error(e);
			}
		};
		
		// 삭제
		function goDeleteBregSpec(breg_seq) {
			$M.goNextPageAjax(this_page+"/"+$M.getValue("cust_no")+"/"+breg_seq+"/remove", '', {method : 'post'},
					function(result) {
						if(result.success) {
							AUIGrid.removeRowByRowId(auiGrid, breg_seq);
						};
					}
				)
		}
		
		// 그리드 생성
		function createAUIGrid() {
			var gridPros = {
				// rowIdField 설정
				rowIdField: "breg_seq",
				// rowIdField가 unique 임을 보장
				rowIdTrustMode: true,
				// rowNumber 
				showRowNumColumn: true,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				softRemoveRowMode: false
			};
			var columnLayout = [
				{ 
					headerText : "사업자번호", 
					dataField : "breg_no", 
					width : "10%", 
					style : "aui-center"
				}, 
				{ 
					headerText : "업체명", 
					dataField : "breg_name", 
					width : "15%", 
					style : "aui-left"
				}, 
				{ 
					headerText : "대표자", 
					dataField : "breg_rep_name", 
					width : "8%", 
					style : "aui-center"
				}, 
				{ 
					headerText : "업태", 
					dataField : "breg_cor_type", 
					width : "15%", 
					style : "aui-center"
				}, 
				{ 
					headerText : "업종", 
					dataField : "breg_cor_part", 
					width : "15%", 
					style : "aui-left",
				}, 
				{ 
					headerText : "사업자구분", 
					dataField : "breg_type_name", 
					width : "10%", 
					style : "aui-center",
				}, 
				{ 
					headerText : "등록자", 
					dataField : "reg_mem_name", 
					width : "8%", 
					style : "aui-center",
				}, 
				{ 
					headerText : "등록일", 
					dataField : "reg_date", 
					dataType : "date",  
					formatString : "yyyy-mm-dd",
					style : "aui-center"
				},
				{ 
					dataField : "biz_post_no", 
					visible : false
				},
				{ 
					dataField : "biz_addr1", 
					visible : false
				},
				{ 
					dataField : "biz_addr2", 
					visible : false
				},
				{ 
					headerText : "삭제", 
					dataField : "breg_seq", 
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							if (confirm("사업자번호("+event.item.breg_no+")를 삭제하시겠습니까?") == true){
								goDeleteBregSpec(event.item.breg_seq);
							}
						},
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item){
				    	return '삭제'
				    },
					style : "aui-center",
					editable : false
				},
				{
					dataField : "real_breg_no",
					visible : false
				}
			];
			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, ${list});
			AUIGrid.bind(auiGrid, "cellClick", function(event){
				try{
					event.item.breg_no = event.item.real_breg_no;
					opener.${inputParam.parent_js_name}(event.item);
					window.close();	
				} catch(e) {
					alert('호출 페이지에서 ${inputParam.parent_js_name} 함수를 구현해주세요.');
				}
			});
		}
		
		function goNew() {
			var param = {
					"cust_no" : $M.getValue("cust_no"),
					"cust_name" : $M.getValue("cust_name"),
					"parent_js_name" : "${inputParam.parent_js_name}",
					"popup_yn" : "Y"
			}
			$M.goNextPage("/cust/cust010501", $M.toGetParam(param));
		}
		
		function fnSetBregInfo(data) {
			opener.${inputParam.parent_js_name}(data);
			window.close();	
		}
		
		function fnClose() {
			window.close();
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="cust_no" name="cust_no">
<input type="hidden" id="hp_no" name="hp_no">
<input type="hidden" id=cust_name name="cust_name">
<!-- 팝업 -->
	<div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <%-- <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/> --%>
            <h2>사업자명세조회</h2>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
        <div class="sub-title-wrap btn-group">
       		<div class="left">
       			<h4><strong class="text-primary" id="cust_info"></strong> 고객님 사업자 내역</h4>
       		</div>
			<div class="right">
				<button class="btn btn-info" onclick="javascript:goNew();">사업자 등록</button>
				<button class="btn btn-info" onclick="javascript:openSearchBregInfoPanel('goSave')">사업자정보 조회</button>
			</div>
		</div>	  
<!-- 검색결과 -->
			<div id="auiGrid" class="mt10" style="width: 100%;height: 300px;"></div>
			<div class="btn-group mt5">
				<div class="left">
				</div>						
				<div class="right">
				<button class="btn btn-info" onclick="javascript:fnClose();">닫기</button>
				</div>
			</div>			
<!-- /검색결과 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>